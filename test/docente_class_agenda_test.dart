import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/docente/data/docente_class_agenda.dart';

void main() {
  test('parses and sorts class agenda events', () {
    final events = parseDocenteClassAgenda('''[
      {"id": "2", "title": "Verifica", "start": "2026-10-05 08:00:00", "end": "2026-10-05 09:00:00",
       "allDay": false, "tipo": "compito", "autore_desc": "BIANCHI MARIO", "materia_desc": null,
       "studente": "", "nota_1": "Capitoli 1-3", "nota_2": ""},
      {"id": "1", "title": "Nota disciplinare", "start": "2026-10-01 10:00:00", "end": "2026-10-01 10:00:00",
       "allDay": false, "tipo": "nota", "autore_desc": "VERDI LUCIA", "studente": "ROSSI ANNA",
       "nota_1": "Disturba la lezione", "nota_2": null}
    ]''');
    expect(events.map((e) => e.id), ['1', '2']);
    expect(events.first.student, 'ROSSI ANNA');
    expect(events.first.kind, 'nota');
    expect(events.last.subject, '');
    expect(events.last.note, 'Capitoli 1-3');
    expect(events.last.start, DateTime(2026, 10, 5, 8));
  });

  test('ignores non-list payloads', () {
    expect(parseDocenteClassAgenda('{"status": "error"}'), isEmpty);
  });
}
