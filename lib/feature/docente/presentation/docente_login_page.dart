import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:registro_elettronico/core/infrastructure/app_injection.dart';
import 'package:registro_elettronico/feature/authentication/data/datasource/registry_provider_preferences.dart';
import 'package:registro_elettronico/feature/authentication/presentation/registry_provider_page.dart';
import 'package:registro_elettronico/feature/docente/data/docente_session_store.dart';
import 'package:registro_elettronico/feature/docente/data/docente_web_api.dart';
import 'package:registro_elettronico/feature/docente/data/webview_cookies.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_experimental.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_navigator_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Runs the official SPID/CIE web login inside a WebView and keeps the
/// resulting web session. Credentials never pass through the app.
class DocenteLoginPage extends StatefulWidget {
  final String? message;

  const DocenteLoginPage({Key? key, this.message}) : super(key: key);

  @override
  _DocenteLoginPageState createState() => _DocenteLoginPageState();
}

class _DocenteLoginPageState extends State<DocenteLoginPage> {
  static const _webLoginHosts = {'web.spaggiari.eu', 'eid.istruzione.it'};

  /// CIE identity server (verified path, handled by the CieID app).
  static const _cieHosts = {
    'idserver.servizicie.interno.gov.it',
    'ios.idserver.servizicie.interno.gov.it',
  };

  WebViewController? _controller;
  String? _userAgent;
  bool _loading = true;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    if (widget.message != null) {
      WidgetsBinding.instance!
          .addPostFrameCallback((_) => _showMessage(widget.message!));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<NavigationDecision> _onNavigation(NavigationRequest request) async {
    _log('navigate${request.isForMainFrame ? '' : ' (subframe)'}', request.url);
    final uri = Uri.tryParse(request.url);
    if (uri == null) return NavigationDecision.navigate;
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      if (request.isForMainFrame && _isCieIdEntry(uri)) {
        await _launchCieId(request.url);
        return NavigationDecision.prevent;
      }
      // EXPERIMENTAL (SPID, not verified): the SPID provider pages stay in
      // the WebView, where the credentials + app notification / QR flow
      // completes in place. Only links followed from a provider page (its
      // "open the app" buttons) go to a provider app through App Links;
      // the redirect from the gateway to the provider is never handed off,
      // or the app would finish the login outside this WebView.
      if (request.isForMainFrame &&
          _isSpidProvider(_currentHost) &&
          !_webLoginHosts.contains(uri.host) &&
          await WebViewCookies.openInNonBrowserApp(request.url)) {
        _log('SPID App Link handed off', request.url);
        return NavigationDecision.prevent;
      }
      return NavigationDecision.navigate;
    }
    _log('handing off to the system', request.url);
    final opened = uri.scheme == 'intent'
        ? await WebViewCookies.openIntentUri(request.url)
        : await launch(request.url);
    if (!opened) _showMessage(docenteText(context, 'docente_auth_app_error'));
    return NavigationDecision.prevent;
  }

  /// Host of the page last loaded, to tell provider pages from redirects.
  String? _currentHost;

  /// Set once a SPID provider page is reached (the SPID path is experimental).
  bool _spid = false;
  bool _spidDismissed = false;

  /// Anything outside Spaggiari, the MIM gateway and the CIE server.
  bool _isSpidProvider(String? host) =>
      host != null &&
      host.isNotEmpty &&
      !_webLoginHosts.contains(host) &&
      !_cieHosts.contains(host) &&
      !host.endsWith('.spaggiari.eu') &&
      !host.endsWith('.istruzione.it');

  void _onPageStarted(String url) {
    _log('page started', url);
    _startedUrl = url;
    setState(() => _loading = true);
    final host = Uri.tryParse(url)?.host;
    if (!_spid && !_spidDismissed && _isSpidProvider(host)) {
      _log('SPID provider page (experimental) $host', '');
      setState(() => _spid = true);
    }
    // Server redirects after the SAML POST may not reach the navigation
    // delegate, so the CIE entry page is also caught when it starts loading.
    final uri = Uri.tryParse(url);
    if (uri != null && _isCieIdEntry(uri)) _launchCieId(url);
  }

  bool _isCieIdEntry(Uri uri) =>
      Platform.isIOS ? isCieIdIosEntry(uri) : isCieIdEntry(uri);

  bool _cieIdInProgress = false;
  String? _startedUrl;

  Future<void> _launchCieId(String url) async {
    if (_cieIdInProgress) return;
    _cieIdInProgress = true;
    _log('launching CieID', url);
    try {
      final result = await WebViewCookies.launchCieId(url);
      _log(
          'CieID result code=${result['resultCode']} error=${result['error']} '
              'hasUrl=${(result['url'] as String?)?.isNotEmpty == true}',
          '');
      final next = result['url'] as String?;
      if (next != null && next.isNotEmpty) {
        _log('loading CieID return', next);
        await _controller?.loadUrl(next);
      } else if (result['error'] == 'not_available') {
        _showMessage(docenteText(context, 'docente_cieid_missing'));
      } else {
        _showMessage(_cieIdErrorMessage(result));
      }
    } finally {
      _cieIdInProgress = false;
    }
  }

  String _cieIdErrorMessage(Map<String, dynamic> result) {
    // Codes from IPZS cieid-android-sdk RedirectionError.
    switch (result['error']) {
      case 1:
        return docenteText(context, 'docente_cieid_not_registered');
      case 2:
        return docenteText(context, 'docente_cieid_auth_failed');
      case 3:
        return docenteText(context, 'docente_cieid_insecure');
    }
    return result['resultCode'] == 0
        ? docenteText(context, 'docente_cieid_cancelled')
        : docenteText(context, 'docente_cieid_error')
            .replaceAll('{code}', '${result['error']}');
  }

  Future<void> _onPageFinished(String url) async {
    _log('page finished', url);
    if (mounted) setState(() => _loading = false);
    if (url != 'about:blank') _currentHost = Uri.tryParse(url)?.host;
    if (url == 'about:blank') {
      if (_userAgent == null) {
        await _startWithMobileUserAgent();
      } else {
        // Changing the user agent reloads the blank page, which would cancel
        // a login load issued earlier: start once that reload is done.
        _openLogin();
      }
      return;
    }
    // Pages skipped by a redirect also report "finished" without ever
    // starting; only pages that actually loaded are inspected.
    if (url != _startedUrl) return;
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host != 'web.spaggiari.eu') return;

    if (uri.path == DocenteWebConfig.profileChoicePath &&
        uri.queryParameters.containsKey('state')) {
      await _checkTeacherProfiles();
    } else if (uri.path == DocenteWebConfig.teacherHomePath) {
      await _completeLogin();
    } else if (uri.path.startsWith('/home/app/default/menu_')) {
      _showMessage(docenteText(context, 'docente_not_teacher_profile'));
    }
  }

  /// The WebView's own user agent is only known once it exists: read it on a
  /// blank page, then start the login presenting the device as a phone.
  Future<void> _startWithMobileUserAgent() async {
    final defaultUserAgent =
        _unquote(await _controller!.evaluateJavascript('navigator.userAgent'));
    setState(() => _userAgent = Platform.isAndroid
        ? mobileUserAgent(defaultUserAgent)
        : defaultUserAgent);
    // Fallback in case the new user agent does not trigger a reload.
    Future.delayed(const Duration(milliseconds: 800), _openLogin);
  }

  bool _loginOpened = false;

  void _openLogin() {
    if (_loginOpened || !mounted) return;
    _loginOpened = true;
    _log('opening SPID/CIE login', DocenteWebConfig.spidLoginUrl);
    _controller?.loadUrl(DocenteWebConfig.spidLoginUrl);
  }

  /// The user picks the profile on Spaggiari's own choice page (each choice
  /// token is valid for 120 seconds); this only warns when none is a teacher.
  Future<void> _checkTeacherProfiles() async {
    try {
      // onPageFinished can fire before the choice page's script has run.
      final raw = await _controller!.evaluateJavascript(
        'typeof utente === "undefined" ? null : '
        'JSON.stringify(utente.profili.map(function (p) {'
        ' return {userType: p.userType, ruolo: p.ruolo}; }))',
      );
      if (raw == 'null') return;
      final profiles = parseProfiles(raw);
      _log(
          'profile choice: ${profiles.length} profiles, '
              '${profiles.where((p) => p.isTeacher).length} teacher',
          '');
      if (!profiles.any((p) => p.isTeacher)) {
        _showMessage(docenteText(context, 'docente_no_teacher_profile'));
      }
    } catch (e) {
      _log('cannot read profiles: $e', '');
    }
  }

  Future<void> _completeLogin() async {
    if (_completing) return;
    _completing = true;
    final cookies = await WebViewCookies.getCookies(DocenteWebConfig.origin);
    final sessionId = sessionIdFromCookieHeader(cookies);
    final userAgent =
        await _controller!.evaluateJavascript('navigator.userAgent');
    if (sessionId == null) {
      _completing = false;
      _showMessage(docenteText(context, 'docente_session_not_found'));
      return;
    }
    await DocenteSessionStore(sl()).write(DocenteSession(
      sessionId: sessionId,
      userAgent: _unquote(userAgent),
    ));
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DocenteNavigatorPage()),
    );
  }

  Future<void> _changeRegistry() async {
    await RegistryProviderPreferences(sl()).clear();
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RegistryProviderPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(docenteText(context, 'docente_login_title')),
        actions: [
          IconButton(
            tooltip: docenteText(context, 'docente_restart'),
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller?.loadUrl(DocenteWebConfig.spidLoginUrl);
            },
          ),
          IconButton(
            tooltip: docenteText(context, 'docente_change_registry'),
            icon: const Icon(Icons.swap_horiz),
            onPressed: _changeRegistry,
          ),
        ],
      ),
      body: Stack(
        children: [
          WebView(
            initialUrl: 'about:blank',
            userAgent: _userAgent,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (controller) => _controller = controller,
            navigationDelegate: _onNavigation,
            onPageStarted: _onPageStarted,
            onPageFinished: _onPageFinished,
            gestureNavigationEnabled: true,
            debuggingEnabled: kDebugMode,
          ),
          if (_loading) const LinearProgressIndicator(),
          if (_spid)
            Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: docenteExperimentalColor,
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.science, color: Colors.white),
                  title: Text(
                    docenteText(context, 'docente_spid_experimental'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() {
                      _spid = false;
                      _spidDismissed = true;
                    }),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void _log(String event, String url) =>
    debugPrint('[DocenteLogin] $event ${redactUrl(url)}');

String _unquote(String value) =>
    value.length >= 2 && value.startsWith('"') && value.endsWith('"')
        ? value.substring(1, value.length - 1)
        : value;
