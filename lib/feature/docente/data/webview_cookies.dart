import 'package:flutter/services.dart';

/// Native access to the WebView cookie store and the CieID hand-off (see
/// MainActivity on Android, AppDelegate on iOS).
class WebViewCookies {
  static const _channel =
      MethodChannel('com.lnlenost.registroelettronico/webview-cookies');

  static Future<String?> getCookies(String url) =>
      _channel.invokeMethod<String>('getCookies', url);

  static Future<void> clear() => _channel.invokeMethod<bool>('clearCookies');

  /// Debug builds only: web path passed with `--es docente_debug_web`.
  static Future<String?> debugWebPath() =>
      _channel.invokeMethod<String>('getDebugWebPath');

  static Future<bool> openIntentUri(String uri) async =>
      await _channel.invokeMethod<bool>('openIntentUri', uri) ?? false;

  /// Hands the CIE login page to the CieID app and waits for the URL the
  /// WebView must load to continue (`{resultCode, url, error}`). On iOS the
  /// app is opened with the `CIEID://` scheme and answers on ours.
  static Future<Map<String, dynamic>> launchCieId(String url) async =>
      Map<String, dynamic>.from(
          await _channel.invokeMethod<Map>('launchCieId', url) ?? const {});

  /// Opens [url] in the app that claims it through an App Link, if any.
  static Future<bool> openInNonBrowserApp(String url) async =>
      await _channel.invokeMethod<bool>('openInNonBrowserApp', url) ?? false;
}
