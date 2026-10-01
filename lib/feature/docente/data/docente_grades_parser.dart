import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:registro_elettronico/feature/docente/data/docente_text.dart';

class DocenteGrade {
  final String value;
  final String date;
  final String component;
  final int period;
  final String note;

  const DocenteGrade({
    required this.value,
    required this.date,
    required this.component,
    required this.period,
    required this.note,
  });

  /// Numeric value for averages: "7+" -> 7.25, "6-" -> 5.75, "6½" -> 6.5.
  double? get numeric {
    final match =
        RegExp(r'^(\d+(?:[.,]\d+)?)\s*(½|\+|-)?$').firstMatch(value.trim());
    if (match == null) return null;
    final base = double.parse(match.group(1)!.replaceAll(',', '.'));
    switch (match.group(2)) {
      case '½':
        return base + 0.5;
      case '+':
        return base + 0.25;
      case '-':
        return base - 0.25;
    }
    return base;
  }
}

class DocenteStudentGrades {
  final String name;
  final List<DocenteGrade> grades;

  const DocenteStudentGrades({required this.name, required this.grades});

  double? get average {
    final values = grades.map((g) => g.numeric).whereType<double>().toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }
}

/// Parses the grades page of a subject (`/cvv/app/default/regvoti.php`): one
/// row per student; each grade is a `td.bottone_voto` whose attributes carry
/// the value (`voto`), date (`mydata`), component (`comp_desc`) and note.
/// Empty slots have `voto` "" or "-".
List<DocenteStudentGrades> parseDocenteGrades(String page) {
  final document = html.parse(page);
  final students = <DocenteStudentGrades>[];
  for (final row in document.querySelectorAll('tr[studente_id]')) {
    final name = row.querySelector('.nome_studente');
    if (name == null) continue;
    students.add(DocenteStudentGrades(
      name: docenteClean(name.text),
      grades: [
        for (final cell in row.querySelectorAll('td.bottone_voto'))
          if (_isGrade(cell.attributes['voto'])) _grade(cell),
      ],
    ));
  }
  return students;
}

bool _isGrade(String? value) =>
    value != null && value.trim().isNotEmpty && value.trim() != '-';

DocenteGrade _grade(Element cell) {
  final periodClass = cell.classes
      .firstWhere((c) => RegExp(r'^q\d$').hasMatch(c), orElse: () => 'q0');
  return DocenteGrade(
    value: cell.attributes['voto']!.trim(),
    date: cell.attributes['mydata'] ?? '',
    component: docenteClean(cell.attributes['comp_desc']),
    period: int.parse(periodClass.substring(1)),
    note: docenteClean(cell.attributes['nota1']),
  );
}
