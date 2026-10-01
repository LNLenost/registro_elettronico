import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/docente/data/docente_grades_parser.dart';

// Same structure as /cvv/app/default/regvoti.php, invented content.
const _page = '''
<table id="data_table_2">
<tr class="rigtab" studente_id="1">
  <td class="registro"><div>1</div></td>
  <td class="elenco_studenti"><div studente_id="1"><div class="nome_studente" studente_id="1">ROSSI ANNA</div><div class="open_sans font_size_8">01-02-2010</div></div></td>
  <td class="bottone_voto registro voto_1 visibile q1" voto="7+" mydata="15-10-2026" comp_desc="Scritto/Grafico" nota1="Verifica cinematica" studente_id="1"></td>
  <td class="bottone_voto registro voto_2 visibile q1" voto="6½" mydata="20-10-2026" comp_desc="Orale" nota1="" studente_id="1"></td>
  <td class="bottone_voto registro voto_2 visibile q1" voto="-" mydata="28-09-2026" comp_desc="Orale" studente_id="1"></td>
  <td class="bottone_voto registro voto_3 visibile q3" voto="" mydata="28-09-2026" studente_id="1"></td>
</tr>
<tr class="rigtab" studente_id="2">
  <td class="elenco_studenti"><div class="nome_studente">VERDI LUCA</div></td>
  <td class="bottone_voto registro voto_1 visibile q3" voto="5-" mydata="10-02-2027" comp_desc="Scritto/Grafico" studente_id="2"></td>
</tr>
<tr class="riga_competenza_default"><td class="bottone_voto" voto=""></td></tr>
</table>
''';

void main() {
  test('parses students and their grades, skipping empty slots', () {
    final students = parseDocenteGrades(_page);
    expect(students.map((s) => s.name), ['ROSSI ANNA', 'VERDI LUCA']);
    final anna = students.first;
    expect(anna.grades.map((g) => g.value), ['7+', '6½']);
    expect(anna.grades.first.component, 'Scritto/Grafico');
    expect(anna.grades.first.note, 'Verifica cinematica');
    expect(anna.grades.first.period, 1);
    expect(students.last.grades.single.period, 3);
  });

  test('computes numeric values and averages', () {
    final anna = parseDocenteGrades(_page).first;
    expect(anna.grades.map((g) => g.numeric), [7.25, 6.5]);
    expect(anna.average, closeTo(6.875, 1e-9));
    expect(
        const DocenteGrade(
                value: 'g', date: '', component: '', period: 1, note: '')
            .numeric,
        isNull);
  });
}
