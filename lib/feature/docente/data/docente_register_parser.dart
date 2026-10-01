import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:registro_elettronico/feature/docente/data/docente_text.dart';

class DocenteSignedLesson {
  final String teacher;
  final String hour;
  final String subject;
  final String subjectShort;
  final String topic;

  const DocenteSignedLesson({
    required this.teacher,
    required this.hour,
    required this.subject,
    required this.subjectShort,
    required this.topic,
  });
}

class DocenteHourMark {
  final String subject;
  final String mark;
  final bool present;

  const DocenteHourMark(
      {required this.subject, required this.mark, required this.present});
}

class DocenteStudentDay {
  final String name;
  final String birthDate;
  final bool present;
  final String status;
  final String statusDescription;
  final List<DocenteHourMark> hours;

  const DocenteStudentDay({
    required this.name,
    required this.birthDate,
    required this.present,
    required this.status,
    required this.statusDescription,
    required this.hours,
  });
}

class DocenteRegisterDay {
  final List<DocenteSignedLesson> lessons;
  final List<DocenteStudentDay> students;

  const DocenteRegisterDay({required this.lessons, required this.students});
}

/// Parses the class register (`/cvv/app/default/regclasse.php`): the
/// "Firma dei docenti" table and the roll call ("appello") rows.
DocenteRegisterDay parseDocenteRegister(String page) {
  final document = html.parse(page);
  return DocenteRegisterDay(
    lessons: [
      for (final row in document.querySelectorAll('tr'))
        if (row.querySelector('td.registro_firma_dett_docente') != null)
          _lesson(row),
    ].where((l) => l.teacher.isNotEmpty || l.hour.isNotEmpty).toList(),
    students: [
      for (final row in document.querySelectorAll('tr.mainrow'))
        if (row.querySelector('td.elenco_studenti') != null) _student(row),
    ],
  );
}

DocenteSignedLesson _lesson(Element row) {
  final subjectCell = row.querySelector('td.registro_firma_dett_materia');
  final spans = subjectCell?.querySelectorAll('span') ?? const <Element>[];
  final topicCell =
      row.querySelector('td.registro_firma_dett_argomento_lezione');
  return DocenteSignedLesson(
    teacher: docenteClean(
        row.querySelector('td.registro_firma_dett_docente > div')?.text),
    hour: docenteClean(row.querySelector('td.registro_firma_dett_ora')?.text),
    subject: docenteClean(
        spans.isNotEmpty ? spans.first.text : subjectCell?.attributes['title']),
    subjectShort: spans.length > 1
        ? docenteClean(spans[1].text).replaceAll(RegExp(r'[()]'), '')
        : '',
    topic: docenteClean(
        topicCell?.querySelector('.registro_firma_dett_argomento_nota')?.text),
  );
}

DocenteStudentDay _student(Element row) {
  final nameCell = row.querySelector('td.elenco_studenti')!;
  final nameDivs = nameCell.querySelectorAll('div');
  final day = row.querySelector('.div_stato_giorno');
  return DocenteStudentDay(
    name:
        docenteClean(nameDivs.isNotEmpty ? nameDivs.first.text : nameCell.text),
    birthDate: nameDivs.length > 1
        ? RegExp(r'\d{2}-\d{2}-\d{4}').stringMatch(nameDivs[1].text) ?? ''
        : '',
    present:
        day == null || !day.classes.any((c) => c.startsWith('f_reg_assenza')),
    status: docenteClean(day?.querySelector('.stato_giorno_shortdesc')?.text),
    statusDescription:
        docenteClean(day?.querySelector('.tim_desc_stato')?.text),
    hours: [
      for (final cell in row.querySelectorAll('td.firma_stato'))
        DocenteHourMark(
          subject: docenteClean(cell.querySelector('.materia_desc')?.text),
          mark: docenteClean(cell.querySelector('.s_reg_testo')?.text),
          present: cell.querySelector('.f_reg_assenza_lezione') == null,
        ),
    ],
  );
}
