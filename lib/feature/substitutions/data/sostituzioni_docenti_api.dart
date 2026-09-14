import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;

const _headers = <String>[
  'Ora',
  'Classe',
  'Doc. Assente',
  'Sost. 1',
  'Sost. 2',
  'Pagam.',
  'Note',
];

/// Read-only client for the public Sostituzioni Docenti teacher room.
class SostituzioniDocentiApi {
  static const _base = 'https://www.sostituzionidocenti.net/fe/';
  final Dio dio;

  SostituzioniDocentiApi({Dio? dio}) : dio = dio ?? Dio();

  Future<List<Map<String, String>>> fetchToday(String schoolCode) async {
    final code = schoolCode.trim();
    if (code.isEmpty) throw ArgumentError('schoolCode cannot be empty');

    final login = await dio.post<String>(
      '$_base' 'controllaCodice.php',
      data: 'pass=${Uri.encodeQueryComponent(code)}',
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        followRedirects: false,
        validateStatus: (status) => status != null && status < 400,
      ),
    );
    final cookies = (login.headers['set-cookie'] ?? const <String>[])
        .map((value) => value.split(';').first)
        .where((value) => value.isNotEmpty)
        .join('; ');
    if (login.statusCode != 302 || cookies.isEmpty) {
      throw StateError('School code was not accepted');
    }

    final page = await dio.get<String>(
      '$_base' 'sostituzioni.php?offset=0',
      options: Options(headers: {'Cookie': cookies}),
    );
    return parseSubstitutionRows(page.data ?? '');
  }
}

List<Map<String, String>> parseSubstitutionRows(String page) {
  return html
      .parse(page)
      .querySelectorAll('table tbody tr')
      .map((row) => row.querySelectorAll('td').map(_text).toList())
      .where((cells) => cells.length >= _headers.length)
      .map((cells) {
        final record = <String, String>{};
        for (var index = 0; index < _headers.length; index++) {
          final value = cells[index];
          if (value.isNotEmpty) record[_headers[index]] = value;
        }
        return record;
      })
      .where((record) => record.isNotEmpty)
      .toList();
}

String _text(dynamic element) => html
    .parseFragment(element.innerHtml.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' '))
    .text
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();
