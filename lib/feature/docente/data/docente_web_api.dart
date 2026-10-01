import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:registro_elettronico/feature/docente/data/docente_class_agenda.dart';
import 'package:registro_elettronico/feature/docente/data/docente_classes_parser.dart';
import 'package:registro_elettronico/feature/docente/data/docente_text.dart';

/// Read-only client for the ClasseViva teacher web area.
///
/// Teachers can only sign in with SPID/CIE, which yields a web session
/// (`PHPSESSID`) rather than a `rest/v1` token. The endpoints below are the
/// JSON calls made by the web pages themselves. Endpoints with side effects
/// (for example opening a circular, which records the read receipt) are
/// intentionally not exposed.
class DocenteWebConfig {
  static const origin = 'https://web.spaggiari.eu';
  static const spidLoginUrl =
      '$origin/home/app/default/loginsp.php?act=spidLogin';
  static const profileChoicePath = '/home/app/default/mspidauth.php';
  static const teacherHomePath = '/home/app/default/menu_classevivadocente.php';
  static const loginPath = '/home/app/default/login.php';
  static const sessionCookie = 'PHPSESSID';
  static const teacherUserType = 'A';
}

class DocenteSessionExpired implements Exception {
  @override
  String toString() => 'Sessione ClasseViva docente scaduta';
}

class DocenteProfile {
  final String userType;
  final String role;

  const DocenteProfile({
    required this.userType,
    required this.role,
  });

  bool get isTeacher => userType == DocenteWebConfig.teacherUserType;

  factory DocenteProfile.fromJson(Map<String, dynamic> json) => DocenteProfile(
        userType: '${json['userType'] ?? ''}',
        role: '${json['ruolo'] ?? ''}',
      );
}

class DocenteAgendaEvent {
  final String id;
  final DateTime? start;
  final DateTime? end;
  final bool allDay;
  final String title;
  final String note;
  final String className;
  final String subject;
  final String kind;

  /// `#RRGGBB` label colour used by the web agenda.
  final String color;

  const DocenteAgendaEvent({
    required this.id,
    required this.start,
    required this.end,
    required this.allDay,
    required this.title,
    required this.note,
    required this.className,
    required this.subject,
    required this.kind,
    this.color = '',
  });

  factory DocenteAgendaEvent.fromJson(Map<String, dynamic> json) =>
      DocenteAgendaEvent(
        id: '${json['id'] ?? ''}',
        start: docenteParseDateTime(json['start']),
        end: docenteParseDateTime(json['end']),
        allDay: json['allDay'] == true,
        title: _text(json['title']),
        note: _text(json['nota']),
        className: _text(json['classe_desc']),
        subject: _text(json['materia_desc']),
        kind: _text(json['tipologia']),
        color: _text(json['backgroundColor']),
      );
}

class DocenteNotice {
  final String id;
  final String code;
  final String title;
  final String text;
  final DateTime? publishedOn;
  final DateTime? expiresOn;
  final String category;
  final bool read;

  const DocenteNotice({
    required this.id,
    required this.code,
    required this.title,
    required this.text,
    required this.publishedOn,
    this.expiresOn,
    required this.category,
    required this.read,
  });

  factory DocenteNotice.fromJson(Map<String, dynamic> json) => DocenteNotice(
        id: '${json['id'] ?? ''}',
        code: '${json['codice'] ?? ''}',
        title: _text(json['titolo']),
        text: _text(json['testo']),
        publishedOn: docenteParseDateTime(json['data_start']),
        expiresOn: docenteParseDateTime(json['data_stop']),
        category: _text(json['tipo_com_desc']),
        read: json['conf_lettura'] != 'non_letto',
      );
}

class DocenteNotices {
  final List<DocenteNotice> unread;
  final List<DocenteNotice> read;

  const DocenteNotices({required this.unread, required this.read});

  factory DocenteNotices.fromJson(Map<String, dynamic> json) => DocenteNotices(
        unread: _objects(json['msg_new'])
            .map((e) => DocenteNotice.fromJson(e))
            .toList(),
        read: _objects(json['read'])
            .map((e) => DocenteNotice.fromJson(e))
            .toList(),
      );
}

class DocenteWebApi {
  final Dio dio;

  DocenteWebApi(this.dio);

  String get userAgent => '${dio.options.headers['User-Agent'] ?? ''}';

  factory DocenteWebApi.forSession({
    required String sessionId,
    required String userAgent,
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: DocenteWebConfig.origin,
      responseType: ResponseType.plain,
      // A redirect (usually to login.php) means the session is gone.
      followRedirects: false,
      validateStatus: (status) => status != null && status < 400,
      headers: {
        'Cookie': '${DocenteWebConfig.sessionCookie}=$sessionId',
        'User-Agent': userAgent,
      },
    ));
    return DocenteWebApi(dio);
  }

  static final _jsonRequest = Options(headers: {
    'X-Requested-With': 'XMLHttpRequest',
    'Accept': 'application/json, text/javascript, */*; q=0.01',
  });

  /// A server-rendered page of the teacher area, for the HTML parsers.
  Future<String> getPage(String pathAndQuery) async {
    final response = await dio.get<List<int>>(
      pathAndQuery,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {'Accept': 'text/html,application/xhtml+xml'},
      ),
    );
    final body = decodeMixedUtf8(response.data ?? const []);
    if ((response.statusCode ?? 0) >= 300 || isDocenteLoginPage(body)) {
      throw DocenteSessionExpired();
    }
    return body;
  }

  Future<String> getUsername() async {
    final json = await _get('/tools/app/default/get_username.php');
    return '${(json as Map)['nome'] ?? ''}';
  }

  Future<List<DocenteAgendaEvent>> getAgenda(DateTime from, DateTime to) async {
    final json = await _get('/acc/app/default/agenda.fn.php', {
      'action': 'get_events',
      'start': formatAgendaBound(from),
      'end': formatAgendaBound(to),
    });
    return _objects(json).map((e) => DocenteAgendaEvent.fromJson(e)).toList();
  }

  Future<DocenteNotices> getNotices() async {
    final response = await dio.post<String>(
      '/sif/app/default/bacheca_personale.php',
      data: {
        'action': 'get_comunicazioni',
        'cerca': '',
        'ncna': '1',
        'tipo_com': ''
      },
      options:
          _jsonRequest.copyWith(contentType: Headers.formUrlEncodedContentType),
    );
    return DocenteNotices.fromJson(
        decodeDocenteResponse(response.statusCode, response.data)
            as Map<String, dynamic>);
  }

  /// Events of a class agenda: the FullCalendar event source of
  /// `/cvv/app/default/agenda.php` (read only, `ope=get_events`).
  Future<List<DocenteClassEvent>> getClassAgenda(
      DocenteLink agendaLink, DateTime from, DateTime to) async {
    final query = Uri.parse(agendaLink.path).queryParameters;
    String bound(DateTime d) => DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(d);
    final response = await dio.post<String>(
      '/cvv/app/default/agenda.php?ope=get_events&mode=agenda&tutte_note=0&nascondi_prenotazioni=0&aula_id=',
      data: {
        'classe_id': query['classe_id'] ?? '',
        'gruppo_id': query['gruppo_id'] ?? '',
        'start': bound(from),
        'end': bound(to),
      },
      options:
          _jsonRequest.copyWith(contentType: Headers.formUrlEncodedContentType),
    );
    return parseDocenteClassAgenda(
        decodeDocenteResponse(response.statusCode, response.data));
  }

  /// Own requests/communications (`ope=get` of the requests service, a
  /// read query answered as JSON; the page sends it as multipart form data).
  Future<dynamic> getRequests(String ownerId, {String status = 'tutte'}) async {
    final response = await dio.post<String>(
      '/ngs/app/default/richieste.exec.php',
      data: FormData.fromMap({
        'ope': 'get',
        'id_anagrafe': ownerId,
        'offset': '0',
        'limit_count': '50',
        'id_assenza': '0',
        'id_evento': '0',
        'stato_richiesta_detail': status,
        'cerca': '',
        'view_rich_no_doc': '0',
        'id_richieste_no_doc': '[]',
        'dal': '',
        'al': '',
        'tipo_periodo': 'data_richiesta',
      }),
      options: _jsonRequest,
    );
    return decodeDocenteResponse(response.statusCode, response.data);
  }

  Future<dynamic> _get(String path, [Map<String, dynamic>? query]) async {
    final response = await dio.get<String>(path,
        queryParameters: query, options: _jsonRequest);
    return decodeDocenteResponse(response.statusCode, response.data);
  }
}

/// The register pages declare UTF-8 but mix in Latin-1 bytes (e.g. "1°
/// Periodo", "lunedì"): valid UTF-8 sequences are decoded as UTF-8 and any
/// other byte as Windows-1252, so neither encoding gets mangled.
String decodeMixedUtf8(List<int> bytes) {
  final out = StringBuffer();
  var i = 0;
  while (i < bytes.length) {
    final b = bytes[i];
    final length = b < 0x80
        ? 1
        : b >= 0xC2 && b <= 0xDF
            ? 2
            : b >= 0xE0 && b <= 0xEF
                ? 3
                : b >= 0xF0 && b <= 0xF4
                    ? 4
                    : 0;
    if (length == 1) {
      out.writeCharCode(b);
      i++;
      continue;
    }
    if (length > 1 && i + length <= bytes.length) {
      final sequence = bytes.sublist(i, i + length);
      if (sequence.skip(1).every((c) => c & 0xC0 == 0x80)) {
        try {
          out.write(utf8.decode(sequence));
          i += length;
          continue;
        } on FormatException {
          // Overlong or surrogate: fall through to single-byte decoding.
        }
      }
    }
    out.writeCharCode(b < 0xA0 ? _cp1252[b - 0x80] ?? b : b);
    i++;
  }
  return out.toString();
}

/// Windows-1252 code points for 0x80-0x9F (null: same as Latin-1); from 0xA0
/// on the two encodings match.
const _cp1252 = <int?>[
  0x20AC, null, 0x201A, 0x0192, 0x201E, 0x2026, 0x2020, 0x2021, //
  0x02C6, 0x2030, 0x0160, 0x2039, 0x0152, null, 0x017D, null,
  null, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014,
  0x02DC, 0x2122, 0x0161, 0x203A, 0x0153, null, 0x017E, 0x0178,
];

/// The login page ("Login CVV Classeviva ...") served instead of the requested
/// page when the session is gone.
bool isDocenteLoginPage(String body) =>
    RegExp(r'<title>\s*Login\b', caseSensitive: false).hasMatch(body);

/// The web endpoints answer JSON with a `text/html` content type; anything
/// that is not JSON (a redirect or the login page) means the session expired.
dynamic decodeDocenteResponse(int? statusCode, String? body) {
  final text = body?.trim() ?? '';
  if (statusCode == null ||
      statusCode >= 300 ||
      !(text.startsWith('{') || text.startsWith('['))) {
    throw DocenteSessionExpired();
  }
  return jsonDecode(text);
}

/// `2026-09-28T00:00:00+02:00`, the format FullCalendar sends to agenda.fn.php.
String formatAgendaBound(DateTime date) {
  final local = DateTime(
      date.year, date.month, date.day, date.hour, date.minute, date.second);
  final offset = local.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final hours = offset.inHours.abs().toString().padLeft(2, '0');
  final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
  String two(int v) => v.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)}'
      'T${two(local.hour)}:${two(local.minute)}:${two(local.second)}$sign$hours:$minutes';
}

/// The CIE login page offers the same-device CieID app flow only when the
/// user agent contains both "Android" and "Mobile"; WebViews on large screens
/// (tablets, foldables) omit "Mobile" and get the QR code flow instead.
String mobileUserAgent(String userAgent) {
  if (userAgent.contains('Mobile') || !userAgent.contains('Safari/')) {
    return userAgent;
  }
  return userAgent.replaceFirst('Safari/', 'Mobile Safari/');
}

/// CIE login pages that the IPZS redirection flow hands to the CieID app
/// (see italia/cieid-android-sdk RedirectionActivity). Exact paths, so the
/// URLs CieID returns (e.g. `livello2mobile`, `livello1e2postqrcode`) keep
/// loading in the WebView.
bool isCieIdEntry(Uri uri) =>
    uri.host == 'idserver.servizicie.interno.gov.it' &&
    (uri.path == '/idp/login/livello2' ||
        uri.path == '/idp/login/livello1' ||
        uri.path.contains('OpenApp'));

/// iOS counterpart of [isCieIdEntry], matched as the IPZS cieid-ios-sdk does:
/// a `livello1` / `livello2` path segment on the CIE identity server, or a
/// `nextUrl` parameter on its `ios.` host. The URL is handed to the CieID app.
bool isCieIdIosEntry(Uri uri) {
  const cieHost = 'idserver.servizicie.interno.gov.it';
  const iosHost = 'ios.$cieHost';
  if (uri.host != cieHost && uri.host != iosHost) return false;
  return uri.pathSegments.contains('livello1') ||
      uri.pathSegments.contains('livello2') ||
      (uri.host == iosHost && uri.queryParameters.containsKey('nextUrl'));
}

/// URL for logs: query parameter names only, values are tokens.
String redactUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme) return url.isEmpty ? '' : '<unparsable>';
  final names = uri.queryParametersAll.keys.join(',');
  return '${uri.scheme}://${uri.host}${uri.path}${names.isEmpty ? '' : '?[$names]'}';
}

/// Extracts `PHPSESSID` from a `Cookie`-style header (Android
/// `CookieManager.getCookie`, or the one AppDelegate builds on iOS).
String? sessionIdFromCookieHeader(String? header) {
  if (header == null) return null;
  for (final part in header.split(';')) {
    final pair = part.trim();
    final prefix = '${DocenteWebConfig.sessionCookie}=';
    if (pair.startsWith(prefix) && pair.length > prefix.length) {
      return pair.substring(prefix.length);
    }
  }
  return null;
}

/// Parses the result of reading `utente.profili` on the profile choice page.
/// Android returns `evaluateJavascript` results JSON-encoded, so a
/// `JSON.stringify` result arrives double-encoded.
List<DocenteProfile> parseProfiles(String raw) {
  dynamic value = jsonDecode(raw);
  if (value is String) value = jsonDecode(value);
  return _objects(value).map((e) => DocenteProfile.fromJson(e)).toList();
}

List<Map<String, dynamic>> _objects(dynamic value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

String _text(dynamic value) => value == null ? '' : '$value'.trim();
