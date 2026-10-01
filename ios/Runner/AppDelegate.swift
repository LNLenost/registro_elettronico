import UIKit
import Flutter
import WebKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private static let cieIdHost = "idserver.servizicie.interno.gov.it"

  /// The CieID app hands the login back through this URL scheme. It is read
  /// from Info.plist, and is not the bundle identifier on purpose: sideloading
  /// tools rewrite that, and CieID would then call back a scheme nobody owns.
  private let urlScheme: String = {
    let types = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]]
    return (types?.first?["CFBundleURLSchemes"] as? [String])?.first ?? "registrocieid"
  }()
  private var pendingCieIdResult: FlutterResult?
  private var cieIdLeftApp = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let registrar = registrar(forPlugin: "WebViewCookies") {
      registerWebViewCookieChannel(registrar.messenger())
    }
    observeCieIdLifecycle()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if handleCieIdReturn(url) { return true }
    return super.application(app, open: url, options: options)
  }

  /// Same channel as MainActivity.kt. The teacher login needs the HttpOnly
  /// PHPSESSID cookie, which JavaScript cannot read. webview_flutter uses the
  /// default WKWebsiteDataStore, so it is the store to read.
  private func registerWebViewCookieChannel(_ messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "com.lnlenost.registroelettronico/webview-cookies",
      binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "getCookies":
        guard let url = (call.arguments as? String).flatMap(URL.init(string:)) else {
          result(nil)
          return
        }
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
          let header = cookies
            .filter { AppDelegate.cookie($0, appliesTo: url) }
            .map { "\($0.name)=\($0.value)" }
            .joined(separator: "; ")
          result(header.isEmpty ? nil : header)
        }
      case "clearCookies":
        WKWebsiteDataStore.default().removeData(
          ofTypes: [WKWebsiteDataTypeCookies],
          modifiedSince: Date(timeIntervalSince1970: 0)
        ) { result(true) }
      case "openInNonBrowserApp":
        // Like an App Link on Android: open only if an app claims the URL.
        guard let url = (call.arguments as? String).flatMap(URL.init(string:)) else {
          result(false)
          return
        }
        UIApplication.shared.open(url, options: [.universalLinksOnly: true]) { opened in
          result(opened)
        }
      case "launchCieId":
        self?.launchCieId(call.arguments as? String, result: result)
      case "openIntentUri":
        result(false)
      case "getDebugWebPath":
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func cookie(_ cookie: HTTPCookie, appliesTo url: URL) -> Bool {
    guard let host = url.host?.lowercased() else { return false }
    let domain = String(cookie.domain.lowercased().drop(while: { $0 == "." }))
    guard host == domain || host.hasSuffix("." + domain) else { return false }
    let path = url.path.isEmpty ? "/" : url.path
    guard path.hasPrefix(cookie.path) else { return false }
    return !cookie.isSecure || url.scheme == "https"
  }

  /// CieID redirection flow (IPZS cieid-ios-sdk, app it.ipzs.cieID): the CIE
  /// login URL the WebView was about to load is handed to the app as
  /// `CIEID://<url>&sourceApp=<our URL scheme>` (the same form the IO app uses).
  /// When the CIE is read, CieID opens `<our URL scheme>:https://<idserver URL>`, which
  /// [handleCieIdReturn] passes back to Dart as `{resultCode, url, error}`.
  private func launchCieId(_ entryUrl: String?, result: @escaping FlutterResult) {
    guard let entryUrl = entryUrl,
      let target = URL(
        string: "CIEID://" + entryUrl + (entryUrl.contains("?") ? "&" : "?")
          + "sourceApp=" + urlScheme)
    else {
      result(["error": "invalid_url"])
      return
    }
    pendingCieIdResult?(["error": "superseded"])
    pendingCieIdResult = result
    cieIdLeftApp = false
    NSLog("[CieID] launching, sourceApp=%@", urlScheme)
    UIApplication.shared.open(target, options: [:]) { [weak self] opened in
      // No app handles the scheme: CieID is not installed.
      guard !opened, let self = self, let pending = self.pendingCieIdResult else { return }
      self.pendingCieIdResult = nil
      pending(["error": "not_available"])
    }
  }

  private func handleCieIdReturn(_ url: URL) -> Bool {
    guard url.scheme?.lowercased() == urlScheme.lowercased() else { return false }
    NSLog("[CieID] return received, pending=%@", pendingCieIdResult == nil ? "no" : "yes")
    guard let pending = pendingCieIdResult else { return true }
    pendingCieIdResult = nil
    // Everything from the first "https://" is the URL the WebView continues with.
    let raw = url.absoluteString.replacingOccurrences(of: "https//", with: "https://")
    guard let start = raw.range(of: "https://") else {
      pending(["resultCode": 1, "error": "invalid_url"])
      return true
    }
    let payload = String(raw[start.lowerBound...])
    // Only ever continue on the CIE identity server: any app can open our scheme.
    guard let next = URLComponents(string: payload), let host = next.host?.lowercased(),
      host == AppDelegate.cieIdHost || host.hasSuffix("." + AppDelegate.cieIdHost)
    else {
      pending(["resultCode": 1, "error": "invalid_url"])
      return true
    }
    if let message = next.queryItems?.first(where: { $0.name == "cieid_error_message" })?.value {
      let text = message.isEmpty ? "unknown" : message.replacingOccurrences(of: "_", with: " ")
      pending(["resultCode": 1, "error": text])
    } else {
      pending(["resultCode": -1, "url": payload])
    }
    return true
  }

  /// If the user comes back from CieID without it opening our URL scheme
  /// (Android always reports a cancel), answer the pending call as cancelled
  /// so the login page does not wait for ever.
  private func observeCieIdLifecycle() {
    let center = NotificationCenter.default
    center.addObserver(
      forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main
    ) { [weak self] _ in
      if self?.pendingCieIdResult != nil { self?.cieIdLeftApp = true }
    }
    center.addObserver(
      forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main
    ) { [weak self] _ in
      guard let self = self, self.cieIdLeftApp else { return }
      self.cieIdLeftApp = false
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
        guard let pending = self?.pendingCieIdResult else { return }
        self?.pendingCieIdResult = nil
        pending(["resultCode": 0])
      }
    }
  }
}
