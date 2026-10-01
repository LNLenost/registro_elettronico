import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/docente/data/docente_register_parser.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_register_page.dart';

// Same structure as /cvv/app/default/regclasse.php, invented content.
const _page = '''
<table>
<tr class="rigtab"><td colspan="48" class="tabella_titolo"> Firma dei docenti </td></tr>
<tr class="rigtab">
  <td class="griglia_sep_gray">&nbsp;</td>
  <td class="registro_firma_dett_docente"><div aria-label="x">MARIO BIANCHI</div><div class="registro_firma_dett_docente_altra_classe"><div>&nbsp;</div></div></td>
  <td class="registro_firma_dett_ora"> 2^ (2) </td>
  <td class="registro_firma_dett_materia" title="FISICA"><span> FISICA&nbsp;</span> <span>(FIS)</span></td>
  <td class="registro_firma_dett_argomento_lezione"><b><span class="font_size_10">Lezione:</span></b>
    <span class="registro_firma_dett_argomento_nota">Moto rettilineo uniforme.</span></td>
</tr>
<tr class="rigtab">
  <td class="registro_firma_dett_docente"><div></div></td>
  <td class="registro_firma_dett_ora"></td>
  <td class="registro_firma_dett_materia"></td>
  <td class="registro_firma_dett_argomento_lezione"><span class="registro_firma_dett_argomento_nota">Non firmata</span></td>
</tr>
</table>
<table>
<tr id="1" class="mainrow rigtab">
  <td class="registro">&nbsp;</td>
  <td class="giustifica cursor_pointer elenco_studenti" studente_id="1"><div>ROSSI ANNA</div><div class="open_sans font_size_8">01-02-2010&nbsp;</div></td>
  <td class="statoassenza_g registro rigtab"><a class="studenti_cambiastato">
    <div class="f_reg_presenza div_stato_giorno"><p class="stato_giorno_shortdesc"> P </p><p class="tim_desc_stato"> Presente </p></div></a></td>
  <td class="registro rigtab firma_stato"><div class="cella40px materia_desc">FIS</div><div class="f_reg_presenza_lezione s_reg_testo"> PL </div></td>
</tr>
<tr id="2" class="mainrow rigtab">
  <td class="giustifica cursor_pointer elenco_studenti" studente_id="2"><div>VERDI LUCA</div><div class="open_sans font_size_8">03-04-2010</div></td>
  <td class="statoassenza_g registro rigtab"><a class="studenti_cambiastato">
    <div class="f_reg_assenza div_stato_giorno"><p class="stato_giorno_shortdesc"> A </p><p class="tim_desc_stato"> Assente </p></div></a></td>
  <td class="registro rigtab firma_stato"><div class="cella40px materia_desc">FIS</div><div class="f_reg_assenza_lezione s_reg_testo"> AL </div></td>
</tr>
<tr id="3" class="mainrow rigtab">
  <td class="giustifica cursor_pointer elenco_studenti" studente_id="3"><div>NERI MARTA</div><div class="open_sans font_size_8">05-06-2010</div></td>
  <td class="statoassenza_g registro rigtab"><a class="studenti_cambiastato">
    <div class="f_reg_assenza_giustificata div_stato_giorno"><p class="stato_giorno_shortdesc"> AG </p><p class="tim_desc_stato"> Assente giustificato </p></div></a></td>
</tr>
</table>
''';

void main() {
  test('parses the signed lessons of the day', () {
    final day = parseDocenteRegister(_page);
    expect(day.lessons, hasLength(1));
    final lesson = day.lessons.single;
    expect(lesson.teacher, 'MARIO BIANCHI');
    expect(lesson.hour, '2^ (2)');
    expect(lesson.subject, 'FISICA');
    expect(lesson.subjectShort, 'FIS');
    expect(lesson.topic, 'Moto rettilineo uniforme.');
  });

  test('docentePathForDay sets the register day', () {
    final path = docentePathForDay(
        '/cvv/app/default/regclasse.php?classe_id=11&gruppo_id=',
        DateTime(2026, 9, 3));
    expect(Uri.parse(path).queryParameters,
        {'classe_id': '11', 'gruppo_id': '', 'data_start': '2026-09-03'});
  });

  test('parses the roll call', () {
    final students = parseDocenteRegister(_page).students;
    expect(students.map((s) => s.name),
        ['ROSSI ANNA', 'VERDI LUCA', 'NERI MARTA']);
    expect(students.first.birthDate, '01-02-2010');
    expect(students.map((s) => s.present), [true, false, false]);
    expect(students[1].statusDescription, 'Assente');
    expect(students[1].hours.single.present, isFalse);
    expect(students.first.hours.single.subject, 'FIS');
  });
}
