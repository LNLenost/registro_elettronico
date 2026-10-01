import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:registro_elettronico/feature/docente/data/docente_text.dart';

/// Kind of a note in the class notes grid, from the icon of its cell.
enum DocenteNoteKind { disciplinary, annotation }

class DocenteNote {
  final String studentId;
  final String student;

  /// `yyyy-MM-dd`, from the cell's `evento_data`.
  final String date;
  final DocenteNoteKind kind;

  /// Tooltip of the cell, when the page provides one; the full text is only
  /// in the page's note dialog, which is not opened.
  final String text;

  const DocenteNote({
    required this.studentId,
    required this.student,
    required this.date,
    required this.kind,
    required this.text,
  });

  DateTime? get day => DateTime.tryParse(date);
}

class DocenteNotesGrid {
  final int students;

  /// Dates of the grid columns (`regclasse.php?data_start=` header links).
  final List<String> dates;
  final List<DocenteNote> notes;

  const DocenteNotesGrid(
      {required this.students, required this.dates, required this.notes});
}

/// EXPERIMENTAL, inferred: parses the class notes page
/// (`/cvv/app/default/gioprof_note.php?classe_id=`). The mapped account had
/// no notes, so what a filled cell looks like is inferred from the empty
/// grid: one row per student (`td.elenco_studenti[studente_id]`), one cell per
/// day (`td[evento_data][studente_id]`); a cell holds a note when it shows the
/// note icon (`img.notaregistro`) or carries an event id (`evento_id`).
DocenteNotesGrid parseDocenteNotes(String page) {
  final document = html.parse(page);
  final dates = <String>[];
  for (final link in document.querySelectorAll('a[href*="data_start="]')) {
    final date = Uri.parse(link.attributes['href']!.replaceAll('&amp;', '&'))
        .queryParameters['data_start'];
    if (date != null && !dates.contains(date)) dates.add(date);
  }
  var students = 0;
  final notes = <DocenteNote>[];
  for (final name in document.querySelectorAll('td.elenco_studenti')) {
    final studentId = name.attributes['studente_id'] ?? '';
    final row = name.parent;
    if (row == null || studentId.isEmpty) continue;
    students++;
    final student = _studentName(name);
    for (final cell in row.querySelectorAll('td[evento_data]')) {
      final icon = cell.querySelector('img.notaregistro');
      final eventId = cell.attributes['evento_id'] ?? '';
      if (icon == null && eventId.isEmpty) continue;
      final src = icon?.attributes['src']?.toLowerCase() ?? '';
      notes.add(DocenteNote(
        studentId: studentId,
        student: student,
        date: cell.attributes['evento_data'] ?? '',
        kind: src.isEmpty || src.contains('nota_alunno')
            ? DocenteNoteKind.disciplinary
            : DocenteNoteKind.annotation,
        text: docenteClean(
            cell.attributes['title'] ?? icon?.attributes['title'] ?? cell.text),
      ));
    }
  }
  notes.sort((a, b) {
    final byDate = b.date.compareTo(a.date);
    return byDate != 0 ? byDate : a.student.compareTo(b.student);
  });
  return DocenteNotesGrid(students: students, dates: dates, notes: notes);
}

/// The name cell also holds the birth date in a second `div`.
String _studentName(Element cell) {
  final first = cell.querySelector('div');
  return docenteClean(first?.text ?? cell.text);
}
