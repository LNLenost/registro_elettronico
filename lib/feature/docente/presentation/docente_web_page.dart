import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:registro_elettronico/feature/docente/data/docente_web_api.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Opens an external Spaggiari service (reached through single sign-on from
/// the teacher menu) in its official interface, with the session cookies the
/// WebView kept from the SPID/CIE login.
class DocenteWebPage extends StatefulWidget {
  final String title;
  final String path;
  final String userAgent;
  final VoidCallback onSessionExpired;

  const DocenteWebPage({
    Key? key,
    required this.title,
    required this.path,
    required this.userAgent,
    required this.onSessionExpired,
  }) : super(key: key);

  @override
  _DocenteWebPageState createState() => _DocenteWebPageState();
}

class _DocenteWebPageState extends State<DocenteWebPage> {
  WebViewController? _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  void _onPageStarted(String url) {
    debugPrint('[DocenteWeb] page started ${redactUrl(url)}');
    setState(() => _loading = true);
    if (Uri.tryParse(url)?.path == DocenteWebConfig.loginPath) {
      Navigator.of(context).pop();
      widget.onSessionExpired();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _controller?.canGoBack() == true) {
          await _controller!.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              tooltip: docenteText(context, 'docente_reload'),
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller?.reload(),
            ),
          ],
        ),
        body: Stack(children: [
          WebView(
            initialUrl: '${DocenteWebConfig.origin}${widget.path}',
            userAgent: widget.userAgent,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (controller) => _controller = controller,
            onPageStarted: _onPageStarted,
            onPageFinished: (_) => setState(() => _loading = false),
            gestureNavigationEnabled: true,
            debuggingEnabled: kDebugMode,
          ),
          if (_loading) const LinearProgressIndicator(),
        ]),
      ),
    );
  }
}
