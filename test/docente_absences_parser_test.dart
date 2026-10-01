import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/docente/data/docente_absences_parser.dart';

String _day(String state, String date) => '''
  <td class="registro f_reg_scuola rigtab"><a id="button_1$date"><span></span>
    <div id="div_1" title="ROSSI ANNA il giorno $date e' stato X" class="$state"><p class="s_reg_testo"> X</p></div></a></td>''';

// Same structure as /cvv/app/default/regassenze.php, invented content.
final _page = '''
<table>
<tr class="rigtab">
  <td class="registro_center"> 1 </td>
  <td class="elenco_studenti registro_center"><div>ROSSI ANNA</div><div class="open_sans font_size_8">01-02-2010</div></td>
  ${_day('f_reg_presenza', '14-09-2026')}
  ${_day('f_reg_assenza_giustificata', '15-09-2026')}
  ${_day('f_reg_assenza', '16-09-2026')}
  ${_day('f_reg_ritardo_giustificato', '17-09-2026')}
  ${_day('f_reg_uscita', '18-09-2026')}
  ${_day('f_reg_festivo', '20-09-2026')}
  <td width="5"></td>
  <td class="registro rigtab"><font></font><b>10</b><div class="f_reg_presenza_stampa"><p class="s_reg_testo"> P</p></div></td>
  <td class="registro rigtab">&nbsp;<b>2</b><font>&nbsp;15%</font><div class="f_reg_assenza"><p class="s_reg_testo"> A</p></div></td>
  <td class="registro rigtab"><font></font>0<div class="f_reg_uscita_pom"><p class="s_reg_testo"> UP</p></div></td>
  <td class="registro rigtab"><font></font>1<div class="f_reg_ritardo"><p class="s_reg_testo"> R</p></div></td>
  <td class="registro rigtab"><font></font>1<div class="f_reg_uscita"><p class="s_reg_testo"> U</p></div></td>
</tr>
</table>
''';

void main() {
  test('parses totals and absence events per student', () {
    final students = parseDocenteAbsences(_page);
    expect(students, hasLength(1));
    final anna = students.single;
    expect(anna.name, 'ROSSI ANNA');
    expect(anna.absences, 2);
    expect(anna.absencePercent, '15%');
    expect(anna.lates, 1);
    expect(anna.exits, 1);
    expect(anna.events.map((e) => e.kind), [
      DocenteAbsenceKind.absence,
      DocenteAbsenceKind.absence,
      DocenteAbsenceKind.late,
      DocenteAbsenceKind.exit,
    ]);
    expect(anna.events.map((e) => e.justified), [true, false, true, false]);
    expect(anna.events.first.date, '15-09-2026');
    expect(anna.unjustified, 2);
  });
}
