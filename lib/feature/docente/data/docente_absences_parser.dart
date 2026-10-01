import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:registro_elettronico/feature/docente/data/docente_text.dart';

enum DocenteAbsenceKind { absence, late, exit }

class DocenteAbsenceEvent {
  final String date;
  final DocenteAbsenceKind kind;
  final bool justified;

  const DocenteAbsenceEvent(
      {required this.date, required this.kind, required this.justified});
}

class DocenteStudentAbsences {
  final String name;
  final int absences;
  final String absencePercent;
  final int lates;
  final int exits;
  final List<DocenteAbsenceEvent> events;

  const DocenteStudentAbsences({
    required this.name,
    required this.absences,
    required this.absencePercent,
    required this.lates,
    required this.exits,
    required this.events,
  });

  int get unjustified => events.where((e) => !e.justified).length;
}

/// Day states: f_reg_assenza[_giustificata], f_reg_ritardo[_giustificato],
/// f_reg_uscita[_giustificata]; presence, holidays and no-lesson days are
/// not events.
DocenteAbsenceKind? _kindOf(String state) {
  if (state.startsWith('f_reg_assenza')) return DocenteAbsenceKind.absence;
  if (state.startsWith('f_reg_ritardo')) return DocenteAbsenceKind.late;
  if (state.startsWith('f_reg_uscita') &&
      !state.startsWith('f_reg_uscita_pom')) {
    return DocenteAbsenceKind.exit;
  }
  return null;
}

/// Parses the absences register (`/cvv/app/default/regassenze.php`): one row
/// per student with a cell per day (`a[id^=button_] > div[title]`, state in
/// the div class, date in its title) followed by the totals cells.
List<DocenteStudentAbsences> parseDocenteAbsences(String page) {
  final document = html.parse(page);
  final students = <DocenteStudentAbsences>[];
  for (final row in document.querySelectorAll('tr')) {
    final nameCell = row.querySelector('td.elenco_studenti');
    if (nameCell == null) continue;
    final events = <DocenteAbsenceEvent>[];
    for (final day in row.querySelectorAll('a[id^="button_"] > div[title]')) {
      final state = day.classes
          .firstWhere((c) => c.startsWith('f_reg_'), orElse: () => '');
      final kind = _kindOf(state);
      if (kind == null) continue;
      events.add(DocenteAbsenceEvent(
        date: RegExp(r'\d{2}-\d{2}-\d{4}')
                .stringMatch(day.attributes['title'] ?? '') ??
            '',
        kind: kind,
        justified: state.contains('giustificat'),
      ));
    }
    Element? total(String cls) {
      for (final cell in row.querySelectorAll('td')) {
        if (cell.querySelector('a[id^="button_"]') == null &&
            cell.querySelector('div.$cls') != null) {
          return cell;
        }
      }
      return null;
    }

    int count(Element? cell) =>
        int.tryParse(RegExp(r'\d+').stringMatch((cell
                        ?.querySelector('b')
                        ?.text ??
                    cell?.nodes.whereType<Text>().map((t) => t.text).join() ??
                    '')
                .trim()) ??
            '') ??
        0;
    final absenceCell = total('f_reg_assenza');
    students.add(DocenteStudentAbsences(
      name: docenteClean(nameCell.querySelector('div')?.text ?? nameCell.text),
      absences: count(absenceCell),
      absencePercent:
          RegExp(r'\d+(?:[.,]\d+)?%').stringMatch(absenceCell?.text ?? '') ??
              '',
      lates: count(total('f_reg_ritardo')),
      exits: count(total('f_reg_uscita')),
      events: events,
    ));
  }
  return students;
}
