import 'package:html/parser.dart' as html;
import 'package:intl/intl.dart';
import 'package:registro_elettronico/feature/docente/data/docente_text.dart';

class DocenteDadStudent {
  final String id;
  final String name;

  /// Days in distance learning (`DD`) of the month.
  final List<DateTime> distanceDays;

  const DocenteDadStudent(
      {required this.id, required this.name, required this.distanceDays});
}

class DocenteDadMonth {
  /// School days of the month (holidays excluded).
  final List<DateTime> schoolDays;
  final List<DocenteDadStudent> students;

  const DocenteDadMonth({required this.schoolDays, required this.students});
}

final _day = DateFormat('dd-MM-yyyy');

/// Parses the distance learning grid of a class
/// (`/cvv/app/default/didattica_distanza.php?classe_id=&data_start=`), one
/// month per page: `tr.rigtab` per student, one `td[data][data_no_barre]`
/// per day with class `f_reg_scuola` (school day) or `f_reg_festivo`.
/// Verified on a class with no distance days. EXPERIMENTAL: how a `DD` day is
/// marked is inferred from the page's own menu (`DD` distance, `DP` in
/// presence): a school day counts as distance when its text is `DD` or it
/// carries a state class other than school / holiday.
DocenteDadMonth parseDocenteDad(String page) {
  final document = html.parse(page);
  final schoolDays = <DateTime>{};
  final students = <DocenteDadStudent>[];
  for (final row in document.querySelectorAll('tr.rigtab')) {
    final box = row.querySelector('[studente_id]');
    final id = box?.attributes['studente_id'] ?? '';
    final nameCell = row.querySelectorAll('td').where((td) =>
        td.classes.contains('open_sans_semibold') &&
        td.querySelector('div') != null);
    final name = nameCell.isEmpty
        ? ''
        : docenteClean(nameCell.first.querySelector('div')!.text);
    final days = <DateTime>[];
    for (final cell in row.querySelectorAll('td[data_no_barre]')) {
      final date = _parseDay(cell.attributes['data']);
      if (date == null || cell.classes.contains('f_reg_festivo')) continue;
      schoolDays.add(date);
      final text = docenteClean(cell.text).toUpperCase();
      final state = cell.classes.where((c) =>
          c.startsWith('f_reg') && c != 'f_reg_scuola' && c != 'f_reg_festivo');
      if (text == 'DD' || (text != 'DP' && state.isNotEmpty)) days.add(date);
    }
    if (id.isNotEmpty || name.isNotEmpty) {
      students.add(DocenteDadStudent(id: id, name: name, distanceDays: days));
    }
  }
  return DocenteDadMonth(
      schoolDays: schoolDays.toList()..sort(), students: students);
}

DateTime? _parseDay(String? value) {
  if (value == null) return null;
  try {
    return _day.parseStrict(value);
  } on FormatException {
    return null;
  }
}
