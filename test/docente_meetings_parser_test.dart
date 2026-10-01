import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/docente/data/docente_meetings_parser.dart';

// Month bar and slot attributes as in /cvv/app/default/gioprof_colloqui.php
// (the slot markup is read by the page script from these attributes).
const _page = '''
<table><tr>
  <td colspan="7"></td>
  <td mese="09" class="mese mese_selezionato">Set</td>
  <td mese="10" class="mese ">Ott</td>
</tr></table>
<div class="jrounded-box" evento_id="2" evento_data="2026-10-12" ora_posizione="3" numero_genitori="2">
  <div>12/10 3^ ora</div><div>Aula 5</div>
</div>
<div class="jrounded-box" evento_id="1" evento_data="2026-10-05" ora_posizione="2" numero_genitori="0">
  <div>05/10 2^ ora</div>
</div>
''';

void main() {
  test('parses the month bar and the meeting slots', () {
    final month = parseDocenteMeetings(_page);
    expect(month.months, {'09': 'Set', '10': 'Ott'});
    expect(month.selected, '09');
    expect(month.meetings.map((m) => m.date), ['2026-10-05', '2026-10-12']);
    expect(month.meetings.last.parents, 2);
    expect(month.meetings.last.hour, '3');
    expect(month.meetings.last.text, '12/10 3^ ora · Aula 5');
    expect(month.meetings.first.day, DateTime(2026, 10, 5));
  });

  test('a month without slots is empty', () {
    expect(
        parseDocenteMeetings(
                '<table><tr><td mese="11" class="mese">Nov</td></tr></table>')
            .meetings,
        isEmpty);
  });
}
