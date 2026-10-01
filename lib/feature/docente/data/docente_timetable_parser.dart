import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:registro_elettronico/feature/docente/data/docente_text.dart';

/// One occupied cell of the teacher timetable.
class DocenteTimetableSlot {
  /// Column of the day, 0 = first day of the table (Monday).
  final int day;

  /// Row of the hour, 0 = first row of the table.
  final int hour;

  /// Number of hours the cell spans (`rowspan`).
  final int span;

  /// Lines of the cell as shown (class, subject, room...).
  final List<String> lines;

  const DocenteTimetableSlot(
      {required this.day,
      required this.hour,
      required this.span,
      required this.lines});
}

class DocenteTimetable {
  final List<String> days;
  final List<String> hours;
  final List<DocenteTimetableSlot> slots;

  /// Periods of the `periodo` select: value -> label.
  final Map<String, String> periods;
  final String? selectedPeriod;

  const DocenteTimetable({
    required this.days,
    required this.hours,
    required this.slots,
    required this.periods,
    required this.selectedPeriod,
  });
}

/// EXPERIMENTAL, inferred: parses the teacher timetable
/// (`/cvv/app/default/orario_docente.php`, period chosen with
/// `?periodo=dd-MM-yyyy&ope=docente`). The mapped school had no timetable, so
/// only the empty table is known: `table#table_orario` with the days in
/// `thead th` after `th.ora`. Rows are read as an hour cell followed by one
/// cell per day, honouring `rowspan` for lessons longer than one hour.
DocenteTimetable parseDocenteTimetable(String page) {
  final document = html.parse(page);
  final periods = <String, String>{};
  String? selected;
  final select = document
      .querySelectorAll('select')
      .where((s) => s.attributes['name'] == 'periodo');
  for (final option in select.expand((s) => s.querySelectorAll('option'))) {
    final value = option.attributes['value'] ?? docenteClean(option.text);
    if (value.isEmpty) continue;
    periods[value] = docenteClean(option.text);
    if (option.attributes.containsKey('selected')) selected = value;
  }
  final table = document.querySelector('#table_orario');
  if (table == null) {
    return DocenteTimetable(
        days: const [],
        hours: const [],
        slots: const [],
        periods: periods,
        selectedPeriod: selected);
  }
  final days = [
    for (final th in table.querySelectorAll('thead th'))
      if (!th.classes.contains('ora')) docenteClean(th.text)
  ];
  final hours = <String>[];
  final slots = <DocenteTimetableSlot>[];
  // Columns still covered by a rowspan of an earlier row: day -> rows left.
  final covered = <int, int>{};
  for (final row in table.querySelectorAll('tbody tr')) {
    final cells = row.children
        .where((c) => c.localName == 'td' || c.localName == 'th')
        .toList();
    if (cells.isEmpty) continue;
    final hour = hours.length;
    hours.add(_lines(cells.first).join(' '));
    var day = 0;
    for (final cell in cells.skip(1)) {
      while ((covered[day] ?? 0) > 0) {
        day++;
      }
      final span = int.tryParse(cell.attributes['rowspan'] ?? '') ?? 1;
      if (span > 1) covered[day] = span;
      final lines = _lines(cell);
      if (lines.isNotEmpty) {
        slots.add(DocenteTimetableSlot(
            day: day, hour: hour, span: span, lines: lines));
      }
      day++;
    }
    covered.updateAll((_, left) => left - 1);
  }
  return DocenteTimetable(
      days: days,
      hours: hours,
      slots: slots,
      periods: periods,
      selectedPeriod: selected);
}

/// Text of a cell split where the page breaks lines (`br`, blocks).
List<String> _lines(Element cell) {
  final buffer = StringBuffer();
  void walk(Node node) {
    if (node is Text) {
      buffer.write(node.text);
    } else if (node is Element) {
      const blocks = {'br', 'div', 'p', 'li', 'tr'};
      if (blocks.contains(node.localName)) buffer.write('\n');
      node.nodes.forEach(walk);
      if (blocks.contains(node.localName)) buffer.write('\n');
    }
  }

  cell.nodes.forEach(walk);
  return buffer
      .toString()
      .split('\n')
      .map(docenteClean)
      .where((line) => line.isNotEmpty)
      .toList();
}
