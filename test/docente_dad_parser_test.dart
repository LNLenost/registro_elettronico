import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/docente/data/docente_dad_parser.dart';

// Grid as in /cvv/app/default/didattica_distanza.php: one tr.rigtab per
// student, one td[data_no_barre] per day. School and holiday states were
// verified; how a distance day is marked is inferred.
const _page = '''
<table>
<tr class="rigtab">
  <td>1</td>
  <td><div class="checkBoxContainer check_box_studente" studente_id="11" classe_id="1"></div></td>
  <td class="bb_grey font_size_10 open_sans_semibold"><div>Rossi Anna</div><div class="font_size_7">01-01-2010</div></td>
  <td class="bb_grey f_reg_festivo rigtab" studente_id="11" data_no_barre="20260905" data="05-09-2026"><span class="s_reg_testo"></span></td>
  <td class="bb_grey f_reg_scuola btn_giorno rigtab" studente_id="11" data_no_barre="20260907" data="07-09-2026"><span class="s_reg_testo"></span></td>
  <td class="bb_grey f_reg_scuola f_reg_dad btn_giorno rigtab" studente_id="11" data_no_barre="20260908" data="08-09-2026"><span class="s_reg_testo">DD</span></td>
</tr>
<tr class="rigtab">
  <td>2</td>
  <td><div class="checkBoxContainer check_box_studente" studente_id="12" classe_id="1"></div></td>
  <td class="bb_grey font_size_10 open_sans_semibold"><div>Bianchi Luca</div></td>
  <td class="bb_grey f_reg_festivo rigtab" data_no_barre="20260905" data="05-09-2026"></td>
  <td class="bb_grey f_reg_scuola btn_giorno rigtab" data_no_barre="20260907" data="07-09-2026"></td>
  <td class="bb_grey f_reg_scuola btn_giorno rigtab" data_no_barre="20260908" data="08-09-2026"></td>
</tr>
</table>
''';

void main() {
  test('school days exclude holidays and distance days are per student', () {
    final month = parseDocenteDad(_page);
    expect(month.schoolDays, [DateTime(2026, 9, 7), DateTime(2026, 9, 8)]);
    expect(month.students.map((s) => s.name), ['Rossi Anna', 'Bianchi Luca']);
    expect(month.students.first.distanceDays, [DateTime(2026, 9, 8)]);
    expect(month.students.last.distanceDays, isEmpty);
  });

  test('a month with only school and holiday days has no distance learning',
      () {
    final month = parseDocenteDad(
        _page.replaceAll(' f_reg_dad', '').replaceAll('>DD<', '><'));
    expect(month.students.every((s) => s.distanceDays.isEmpty), isTrue);
  });
}
