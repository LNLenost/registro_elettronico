import 'package:html/parser.dart' as html;
import 'package:registro_elettronico/feature/docente/data/docente_text.dart';

class DocenteJournalLesson {
  final String className;
  final String subject;
  final String date;
  final String hour;
  final String teacher;
  final String activity;
  final String topic;

  const DocenteJournalLesson({
    required this.className,
    required this.subject,
    required this.date,
    required this.hour,
    required this.teacher,
    required this.activity,
    required this.topic,
  });

  /// `dd/MM/yyyy` as a sortable date.
  DateTime? get day {
    final m = RegExp(r'(\d{2})/(\d{2})/(\d{4})').firstMatch(date);
    return m == null
        ? null
        : DateTime(int.parse(m.group(3)!), int.parse(m.group(2)!),
            int.parse(m.group(1)!));
  }
}

/// Parses the teacher journal (`/cvv/app/default/gioprof.php`): the lessons
/// table `#sort_table` (Classe, Materia, Giorno, Ora, Docente, Argomento, UDA).
List<DocenteJournalLesson> parseDocenteJournal(String page) {
  final document = html.parse(page);
  final lessons = <DocenteJournalLesson>[];
  for (final row in document.querySelectorAll('#sort_table tbody tr')) {
    final cells = row.querySelectorAll('td');
    if (cells.length < 6) continue;
    final topicCell = cells[5];
    lessons.add(DocenteJournalLesson(
      className: docenteClean(cells[0].text),
      subject: docenteClean(cells[1].text),
      date: docenteClean(cells[2].text),
      hour: docenteClean(cells[3].text),
      teacher: docenteClean(cells[4].text),
      activity: docenteClean(topicCell.querySelector('.attivita')?.text),
      topic: [
        docenteClean(topicCell.querySelector('.nota_1')?.text),
        docenteClean(topicCell.querySelector('.nota_2')?.text),
      ].where((s) => s.isNotEmpty).join('\n'),
    ));
  }
  lessons
      .sort((a, b) => (b.day ?? DateTime(0)).compareTo(a.day ?? DateTime(0)));
  return lessons;
}
