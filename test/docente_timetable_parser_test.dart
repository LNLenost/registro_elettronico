import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/docente/data/docente_timetable_parser.dart';

// Form and header as in /cvv/app/default/orario_docente.php; the body rows
// are inferred (the mapped school had no timetable).
const _page = '''
<form class="form-inline"><select class="btn btn-default" name="periodo">
  <option value="14-09-2026">14/09 - 19/09</option>
  <option value="28-09-2026" selected>28/09 - 03/10</option>
</select><input type="hidden" name="ope" value="docente"></form>
<table id="table_orario" class="table table-striped spg-tablet">
<thead><tr><th class="ora"></th><th>Luned&igrave;</th><th>Marted&igrave;</th><th>Mercoled&igrave;</th></tr></thead>
<tbody>
<tr><th class="ora">1&ordf; 08:00</th><td rowspan="2">3TELB<br>Informatica<br>Lab 2</td><td></td><td>4ELEA</td></tr>
<tr><th class="ora">2&ordf; 09:00</th><td>4TELA<br>Sistemi</td><td></td></tr>
</tbody></table>
''';

void main() {
  test('reads days, hours, periods and lessons honouring rowspan', () {
    final t = parseDocenteTimetable(_page);
    expect(t.days, ['Lunedì', 'Martedì', 'Mercoledì']);
    expect(t.hours, ['1ª 08:00', '2ª 09:00']);
    expect(t.periods.keys, ['14-09-2026', '28-09-2026']);
    expect(t.selectedPeriod, '28-09-2026');
    expect(t.slots, hasLength(3));
    final monday = t.slots.first;
    expect(monday.day, 0);
    expect(monday.span, 2);
    expect(monday.lines, ['3TELB', 'Informatica', 'Lab 2']);
    expect(t.slots[1].day, 2);
    // Monday is still covered in the second row: its first cell is Tuesday.
    expect(t.slots[2].day, 1);
    expect(t.slots[2].hour, 1);
    expect(t.slots[2].lines, ['4TELA', 'Sistemi']);
  });

  test('the empty table of the mapped school', () {
    final t = parseDocenteTimetable('<table id="table_orario"><thead><tr>'
        '<th class="ora"></th><th>Luned&igrave;</th></tr></thead>'
        '<tbody></tbody></table>');
    expect(t.days, ['Lunedì']);
    expect(t.slots, isEmpty);
  });
}
