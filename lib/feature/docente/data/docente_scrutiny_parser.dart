import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:registro_elettronico/feature/docente/data/docente_classes_parser.dart';
import 'package:registro_elettronico/feature/docente/data/docente_text.dart';

const docenteScrutinyPath = '/sol/app/default/gioprof_scrutinionline.php';

/// Parses the scrutiny classes (`/sol/app/default/gioprof_scrutinionline.php`,
/// "Le mie classi" of the online scrutiny): one row per class with the class
/// name (`td.font_size_28`) and one `div.rigtab.materia_*` per subject, whose
/// links ("Voti proposti", "Infraquad.") open `regvoti_proposti.php`.
/// Verified on device.
List<DocenteClass> parseDocenteScrutinyClasses(String page) {
  final document = html.parse(page);
  final base = Uri.parse(docenteScrutinyPath);
  String resolve(String href) {
    final uri = base.resolve(href.trim());
    return uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
  }

  final classes = <DocenteClass>[];
  for (final nameCell in document.querySelectorAll('td.font_size_28')) {
    final row = nameCell.parent!;
    final subjects = <DocenteSubject>[];
    for (final subject in row.querySelectorAll('div.rigtab')) {
      if (!subject.classes.any((c) => c.startsWith('materia_'))) continue;
      final name = docenteClean(
          subject.querySelector('span.open_sans_condensed_bold')?.text);
      subjects.add(DocenteSubject(name: name, links: [
        for (final a in subject.querySelectorAll('a[href]'))
          DocenteLink(docenteClean(a.text), resolve(a.attributes['href']!)),
      ]));
    }
    final info = row.querySelector('p.font_size_12');
    classes.add(DocenteClass(
      name: docenteClean(nameCell.text),
      description: '',
      course: docenteClean(info?.text),
      links: const [],
      subjects: subjects,
    ));
  }
  return classes;
}

/// Proposed grade of one component (written, oral, practical, single).
class DocenteProposal {
  final String component;

  /// Average of the period's grades for the component, as the page shows it.
  final String average;

  /// Proposed grade (`VP`); empty until the teacher proposes one.
  final String grade;

  const DocenteProposal(
      {required this.component, required this.average, required this.grade});
}

class DocenteStudentProposals {
  final String name;
  final List<DocenteProposal> proposals;
  final String absences;
  final String note;
  final String recovery;

  const DocenteStudentProposals({
    required this.name,
    required this.proposals,
    required this.absences,
    required this.note,
    required this.recovery,
  });
}

class DocenteProposalsPeriod {
  final String id;
  final String name;
  final List<DocenteStudentProposals> students;

  const DocenteProposalsPeriod(
      {required this.id, required this.name, required this.students});
}

final _cellId = RegExp(r'^(VP|AS|NN|RR)_\d*S(\d+)');

/// Parses the proposed grades of a class and subject
/// (`/cvv/app/default/regvoti_proposti.php`): periods in
/// `td.registro_voti_testata_periodo` (`th_ss_S<n>`), components in
/// `td.registro_voti_testata_componenti` (`th_cc_S<n>_<i>`), then one
/// `tr.rigtab` per student where each component is a `td.media` (attribute
/// `media`) followed by its `VP_<student>S<n>_<i>` cell, and the period ends
/// with absences (`AS_`, attribute `assenze`), note (`NN_`) and recovery
/// (`RR_`). Headers, averages and absences verified on device; EXPERIMENTAL:
/// the proposed grade (attribute `voto`, or the cell text) was empty on the
/// mapped account.
List<DocenteProposalsPeriod> parseDocenteProposals(String page) {
  final document = html.parse(page);
  final periodNames = <String, String>{};
  for (final cell
      in document.querySelectorAll('td.registro_voti_testata_periodo')) {
    final id = cell.id.replaceFirst('th_ss_', '');
    periodNames[id] = docenteClean(cell.text);
  }
  final components = <String, List<String>>{};
  for (final cell
      in document.querySelectorAll('td.registro_voti_testata_componenti')) {
    final match = RegExp(r'^th_cc_(S\d+)_').firstMatch(cell.id);
    if (match == null) continue;
    components
        .putIfAbsent(match.group(1)!, () => [])
        .add(docenteClean(cell.text));
  }
  final students = <String, List<DocenteStudentProposals>>{
    for (final id in periodNames.keys) id: []
  };
  for (final row in document.querySelectorAll('tr.rigtab')) {
    final nameCell = row.querySelector('td.elenco_studenti');
    if (nameCell == null) continue;
    final name = docenteClean(
        nameCell.querySelector('div > div')?.text ?? nameCell.text);
    final byPeriod = <String, _StudentPeriod>{};
    String? pendingAverage;
    for (final cell in row.children) {
      if (cell.classes.contains('media')) {
        pendingAverage = docenteClean(cell.attributes['media']);
        continue;
      }
      final match = _cellId.firstMatch(cell.id);
      if (match == null) continue;
      final period = 'S${match.group(2)}';
      final data = byPeriod.putIfAbsent(period, () => _StudentPeriod());
      switch (match.group(1)) {
        case 'VP':
          final labels = components[period] ?? const [];
          final index = data.proposals.length;
          data.proposals.add(DocenteProposal(
            component: index < labels.length ? labels[index] : '',
            average: pendingAverage ?? '',
            grade: _value(cell, 'voto'),
          ));
          pendingAverage = null;
          break;
        case 'AS':
          data.absences = _value(cell, 'assenze');
          break;
        case 'NN':
          data.note = _value(cell, 'nota');
          break;
        case 'RR':
          data.recovery = _value(cell, 'recupero_display');
          break;
      }
    }
    byPeriod.forEach((period, data) {
      students.putIfAbsent(period, () => []).add(DocenteStudentProposals(
            name: name,
            proposals: data.proposals,
            absences: data.absences,
            note: data.note,
            recovery: data.recovery,
          ));
    });
  }
  return [
    for (final entry in students.entries)
      DocenteProposalsPeriod(
          id: entry.key,
          name: periodNames[entry.key] ?? entry.key,
          students: entry.value),
  ];
}

class _StudentPeriod {
  final proposals = <DocenteProposal>[];
  String absences = '';
  String note = '';
  String recovery = '';
}

/// Attribute value, or the cell text when the attribute is empty.
String _value(Element cell, String attribute) {
  final value = docenteClean(cell.attributes[attribute]);
  return value.isNotEmpty ? value : docenteClean(cell.text);
}
