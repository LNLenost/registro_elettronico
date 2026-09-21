import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

class DidUpConfig {
  static const apiBaseUrl = 'https://didattica.portaleargo.it/famiglia/api';
  static const authorizationUrl = 'https://auth.portaleargo.it/oauth2/auth';
  static const tokenUrl = 'https://auth.portaleargo.it/oauth2/token';
  static const clientId = '72fd6dea-d0ab-4bb9-8eaa-3ac24c84886c';
  static const redirectUri = 'it.argosoft.didup.famiglia.new://login-callback';
  static const clientVersion = '1.30.2';

  const DidUpConfig();
}

class DidUpPkceRequest {
  final String state;
  final String nonce;
  final String verifier;
  final String challenge;

  const DidUpPkceRequest({
    required this.state,
    required this.nonce,
    required this.verifier,
    required this.challenge,
  });
}

class DidUpSession {
  final String accessToken;
  final String? refreshToken;
  final String? appToken;
  final String? codMin;
  final DateTime? expiresAt;

  const DidUpSession({
    required this.accessToken,
    this.refreshToken,
    this.appToken,
    this.codMin,
    this.expiresAt,
  });

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!.subtract(const Duration(seconds: 30)));
}

class DidUpDashboard {
  final Map<String, dynamic> data;

  const DidUpDashboard(this.data);

  List<Map<String, dynamic>> list(String key) {
    final value = data[key];
    if (value is! List) return const <Map<String, dynamic>>[];
    return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  List<Map<String, dynamic>> get grades => list('voti');
  List<Map<String, dynamic>> get absences => list('appello');
  List<Map<String, dynamic>> get register => list('registro');
  List<Map<String, dynamic>> get notices => list('bacheca');
  List<Map<String, dynamic>> get studentNotices => list('bachecaAlunno');
  List<Map<String, dynamic>> get reminders => list('promemoria');
  List<Map<String, dynamic>> get teachers => list('listaDocentiClasse');
  List<Map<String, dynamic>> get periods => list('listaPeriodi');
  List<Map<String, dynamic>> get subjects => list('listaMaterie');
}

/// Client for the read contract extracted from didUP Famiglia 1.30.2.
///
/// OAuth2/PKCE is intentionally kept outside this class: the callback must be
/// handled by the platform without copying credentials or tokens through UI.
class DidUpRemoteDatasource {
  final Dio dio;
  final DidUpConfig config;
  DidUpSession? _session;
  Map<String, dynamic> _appOptions = <String, dynamic>{};

  DidUpRemoteDatasource({Dio? dio, this.config = const DidUpConfig()})
      : dio = dio ?? Dio();

  DidUpSession? get session => _session;

  DidUpPkceRequest createPkceRequest() {
    final verifier = _randomString(64);
    return DidUpPkceRequest(
      state: _randomString(32),
      nonce: _randomString(32),
      verifier: verifier,
      challenge: base64Url
          .encode(sha256.convert(utf8.encode(verifier)).bytes)
          .replaceAll('=', ''),
    );
  }

  void setSession(DidUpSession session) {
    _session = session;
  }

  Uri authorizationUri({
    required String state,
    required String nonce,
    required String codeChallenge,
  }) {
    return Uri.parse(DidUpConfig.authorizationUrl).replace(queryParameters: {
      'redirect_uri': DidUpConfig.redirectUri,
      'client_id': DidUpConfig.clientId,
      'response_type': 'code',
      'prompt': 'login',
      'state': state,
      'nonce': nonce,
      'scope': 'openid offline profile user.roles argo',
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
    });
  }

  Future<DidUpSession> exchangeCode({
    required String code,
    required String codeVerifier,
  }) async {
    final response = await dio.post(
      DidUpConfig.tokenUrl,
      data: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': DidUpConfig.redirectUri,
        'client_id': DidUpConfig.clientId,
        'code_verifier': codeVerifier,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return _saveToken(response.data as Map<String, dynamic>);
  }

  Future<DidUpSession> refresh() async {
    final refreshToken = _session?.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      throw StateError('didUP refresh token non disponibile');
    }
    final response = await dio.post(
      DidUpConfig.tokenUrl,
      data: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': DidUpConfig.clientId,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return _saveToken(response.data as Map<String, dynamic>);
  }

  Future<DidUpSession> applicationLogin() async {
    final response = await _post('login', {
      'lista-opzioni-notifiche': '{}',
      'lista-x-auth-token': '[]',
      'clientID': _randomClientId(),
    });
    final data = _asMap(response['data']);
    if (data.isEmpty) throw StateError('didUP non ha restituito un profilo');
    _appOptions = _optionsFrom(data['opzioni']);
    final current = _session;
    return _session = DidUpSession(
      accessToken: current!.accessToken,
      refreshToken: current.refreshToken,
      expiresAt: current.expiresAt,
      appToken: data['token'] as String?,
      codMin: data['codMin'] as String?,
    );
  }

  Future<DidUpDashboard> dashboard({String? lastUpdate}) async {
    if (_session == null) throw StateError('didUP non autenticato');
    final response = await _post('dashboard/dashboard2', {
      'dataultimoaggiornamento': lastUpdate ?? '2000-01-01 00:00:00.000',
      'opzioni': jsonEncode(_options()),
    });
    final root = _asMap(response['data']);
    final rows = root['dati'];
    final data = rows is List && rows.isNotEmpty ? _asMap(rows.first) : root;
    return DidUpDashboard(data);
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final response = await dio.post(
      '${DidUpConfig.apiBaseUrl}/$path',
      data: body,
      options: Options(headers: _headers()),
    );
    final data = _asMap(response.data);
    if (data['success'] == false) {
      throw StateError(data['msg']?.toString() ?? 'didUP richiesta fallita');
    }
    return data;
  }

  Map<String, String> _headers() {
    final current = _session;
    return <String, String>{
      'accept': 'application/json',
      'content-type': 'application/json; charset=utf-8',
      'argo-client-version': DidUpConfig.clientVersion,
      if (current != null) 'authorization': 'Bearer ${current.accessToken}',
      if (current?.appToken != null) 'x-auth-token': current!.appToken!,
      if (current?.codMin != null) 'x-cod-min': current!.codMin!,
    };
  }

  DidUpSession _saveToken(Map<String, dynamic> data) {
    final expires = data['expires_in'];
    return _session = DidUpSession(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String?,
      expiresAt: expires is num
          ? DateTime.now().add(Duration(seconds: expires.toInt()))
          : null,
    );
  }

  Map<String, dynamic> _options() => _appOptions;

  static Map<String, dynamic> _optionsFrom(dynamic value) {
    if (value is! List) return <String, dynamic>{};
    final result = <String, dynamic>{};
    for (final item in value) {
      if (item is Map && item['chiave'] != null) {
        result[item['chiave'].toString()] = item['valore'];
      }
    }
    return result;
  }

  static Map<String, dynamic> _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  static String _randomClientId() {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List<String>.generate(
      163,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
  }

  static String _randomString(int length) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List<String>.generate(
      length,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
  }
}
