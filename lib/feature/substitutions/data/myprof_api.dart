import 'package:dio/dio.dart';

/// Read-only adapter for MyProf/Sostituzioni Docenti.
/// ponytail: one provider adapter, no duplicate repository until the API is stable.
class MyProfApi {
  static const publicBase =
      'https://www.sostituzionidocenti.net/webtest_agav/api/src/';

  final Dio dio;
  String? _schoolApi;

  MyProfApi({Dio? dio}) : dio = dio ?? Dio();

  Future<MyProfSchoolResult> initSchool(String schoolCode) async {
    final code = schoolCode.trim();
    if (code.isEmpty) throw ArgumentError('schoolCode cannot be empty');
    final response = await dio.post(
      '${publicBase}connetti_inizio.php',
      data: {'codScuola': code, 'uncodedCodScuola': code},
      options: Options(responseType: ResponseType.json),
    );
    final body = _map(response.data);
    if (body['status'] == 'expired') return MyProfSchoolResult.expired(code);
    _schoolApi = _normaliseApi(body['urldb']?.toString());
    return MyProfSchoolResult(
      code: code,
      expired: false,
      apiBase: _schoolApi,
      raw: body,
    );
  }

  Future<bool> isSchoolCodeValid(String schoolCode) async {
    final code = schoolCode.trim();
    if (code.isEmpty) return false;
    final response = await dio.get(
      '${publicBase}get_scuola_by_codice.php',
      queryParameters: {'codice': code},
    );
    return response.data != null && response.data.toString() != 'null';
  }

  Future<List<Map<String, dynamic>>> substitutionsForHour({
    required int id,
    required DateTime date,
    required int hour,
  }) async {
    final data = await _get('get_supplenze_giorno.php', {
      'id': id,
      'data': _date(date),
      'ora': hour,
    });
    return _list(data);
  }

  Future<List<Map<String, dynamic>>> timetableForClass({
    required int weekday,
    required String weekdayName,
  }) async {
    return _list(await _get('get_orario_giorno_classi.php', {
      'gg': weekday,
      'giorno': weekdayName,
    }));
  }

  Future<Map<String, dynamic>> timetableForTeacher({
    required int weekday,
    required int teacherId,
  }) async {
    return _map(await _get('get_orario_giorno_docente.php', {
      'numGiorno': weekday,
      'id': teacherId,
    }));
  }

  Future<List<Map<String, dynamic>>> classesForDay(int weekday) async {
    return _list(await _get('get_classe_giorno.php', {'gg': weekday}));
  }

  Future<dynamic> _get(String endpoint, Map<String, dynamic> query) async {
    final base = _schoolApi;
    if (base == null) {
      throw StateError('Call initSchool before using MyProf data endpoints');
    }
    final response = await dio.get('$base$endpoint', queryParameters: query);
    return response.data;
  }

  static String? _normaliseApi(String? value) {
    if (value == null || value.isEmpty) return null;
    return value.endsWith('/') ? value : '$value/';
  }

  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static Map<String, dynamic> _map(dynamic value) => value is Map
      ? Map<String, dynamic>.from(value as Map)
      : <String, dynamic>{};

  static List<Map<String, dynamic>> _list(dynamic value) => value is List
      ? value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList()
      : <Map<String, dynamic>>[];
}

class MyProfSchoolResult {
  final String code;
  final bool expired;
  final String? apiBase;
  final Map<String, dynamic> raw;

  const MyProfSchoolResult({
    required this.code,
    required this.expired,
    this.apiBase,
    this.raw = const <String, dynamic>{},
  });

  const MyProfSchoolResult.expired(String code)
      : this(code: code, expired: true);
}
