import 'dart:convert';

import 'package:registro_elettronico/feature/docente/data/docente_text.dart';

/// An event of the class agenda (`/cvv/app/default/agenda.php`, JSON mode):
/// homework, tests, notes for students and other class events.
class DocenteClassEvent {
  final String id;
  final String title;
  final DateTime? start;
  final DateTime? end;
  final bool allDay;
  final String kind;
  final String author;
  final String subject;
  final String student;
  final String note;

  const DocenteClassEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.allDay,
    required this.kind,
    required this.author,
    required this.subject,
    required this.student,
    required this.note,
  });

  factory DocenteClassEvent.fromJson(Map<String, dynamic> json) =>
      DocenteClassEvent(
        id: '${json['id'] ?? ''}',
        title: _text(json['title']),
        start: docenteParseDateTime(json['start']),
        end: docenteParseDateTime(json['end']),
        allDay: json['allDay'] == true,
        kind: _text(json['tipo']),
        author: _text(json['autore_desc']),
        subject: _text(json['materia_desc']),
        student: _text(json['studente']),
        note: [_text(json['nota_1']), _text(json['nota_2'])]
            .where((s) => s.isNotEmpty)
            .join('\n'),
      );
}

List<DocenteClassEvent> parseDocenteClassAgenda(dynamic json) {
  final value = json is String ? jsonDecode(json) : json;
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((e) => DocenteClassEvent.fromJson(Map<String, dynamic>.from(e)))
      .toList()
    ..sort(
        (a, b) => (a.start ?? DateTime(0)).compareTo(b.start ?? DateTime(0)));
}

String _text(dynamic value) =>
    value == null ? '' : '$value'.replaceAll(RegExp(r'\s+'), ' ').trim();
