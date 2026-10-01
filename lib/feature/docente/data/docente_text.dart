final _nbsp = String.fromCharCode(0xA0);
final _spaces = RegExp(r'\s+');

/// Text of a web page node as shown: non-breaking spaces become spaces and
/// whitespace runs collapse.
String docenteClean(String? text) =>
    (text ?? '').replaceAll(_nbsp, ' ').replaceAll(_spaces, ' ').trim();

/// Web timestamps come as `2026-09-28 08:00:00`; null if missing or invalid.
DateTime? docenteParseDateTime(dynamic value) =>
    value == null ? null : DateTime.tryParse('$value'.replaceFirst(' ', 'T'));
