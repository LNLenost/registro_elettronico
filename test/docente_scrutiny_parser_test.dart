import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/docente/data/docente_scrutiny_parser.dart';

// Classes list as in /sol/app/default/gioprof_scrutinionline.php.
const _classes = '''
<table><tr>
  <td class="open_sans_extrabold griglia_sep_gray font_size_28 redtext">3TELB</td>
  <td class="griglia_sep_gray font_size_22"><div><p class="font_size_12"><font class="bluetext">Sezione TELB</font></p><p class="graytext">Plesso: X</p></div></td>
  <td class="griglia_sep_gray">
    <div class="rigtab materia_1_0">
      <div><span class="open_sans_condensed_bold font_size_12">Telecomunicazioni</span></div>
      <div class="font_size_10">
        <div><a href="../../../cvv/app/default/regvoti_proposti.php?scrutinionline=1&amp;classe_id=10&amp;gruppo_id=&amp;materia_id=5"><span>Voti proposti</span></a></div>
        <div><a href="../../../cvv/app/default/regvoti_proposti.php?classe_id=10&amp;gruppo_id=&amp;infra=1&amp;materia_id=5"><span>Infraquad.</span></a></div>
      </div>
    </div>
  </td>
</tr></table>
''';

// Proposed grades as in /cvv/app/default/regvoti_proposti.php: periods,
// components, and per student media / VP cells followed by absences, notes.
const _proposals = '''
<table>
<tr><td id="th_ss_S1" class="registro_voti_testata_periodo"><span>1° Periodo</span></td>
    <td id="th_ss_S3" class="registro_voti_testata_periodo"><span>2° Periodo</span></td></tr>
<tr><td id="th_cc_S1_1" class="registro_voti_testata_componenti">Scritto</td>
    <td id="th_cc_S1_2" class="registro_voti_testata_componenti">Orale</td>
    <td id="th_cc_S3_1" class="registro_voti_testata_componenti">Unico</td></tr>
<tr class="rigtab">
  <td class="registro">1</td>
  <td id="th_studente_11" class="elenco_studenti"><div><div>Rossi Anna</div><div>01-01-2010</div></div></td>
  <td class="media registro" media="6,5"></td>
  <td id="VP_11S1_1" class="bottone_VP registro" voto="7"></td>
  <td class="media registro" media=""></td>
  <td id="VP_11S1_2" class="bottone_VP registro" voto=""></td>
  <td id="AS_11S1" class="registro" assenze="3">3</td>
  <td id="NN_11S1" class="registro" nota=""></td>
  <td id="RR_11S1" class="registro" recupero_display=""></td>
  <td class="media registro" media="8"></td>
  <td id="VP_11S3_1" class="registro" voto=""></td>
  <td id="AS_11S3" class="registro" assenze="0">0</td>
  <td id="NN_11S3" class="registro" nota=""></td>
  <td id="RR_11S3" class="registro" recupero_display=""></td>
</tr>
</table>
''';

void main() {
  test('scrutiny classes with their subject links', () {
    final classes = parseDocenteScrutinyClasses(_classes);
    expect(classes, hasLength(1));
    expect(classes.first.name, '3TELB');
    expect(classes.first.course, 'Sezione TELB');
    final subject = classes.first.subjects.single;
    expect(subject.name, 'Telecomunicazioni');
    expect(subject.links.map((l) => l.label), ['Voti proposti', 'Infraquad.']);
    expect(
        subject.links.first.path,
        '/cvv/app/default/regvoti_proposti.php?scrutinionline=1&classe_id=10&gruppo_=&materia_id=5'
            .replaceAll('gruppo_=', 'gruppo_id='));
  });

  test('proposed grades per period and component', () {
    final periods = parseDocenteProposals(_proposals);
    expect(periods.map((p) => p.name), ['1° Periodo', '2° Periodo']);
    final first = periods.first.students.single;
    expect(first.name, 'Rossi Anna');
    expect(first.proposals.map((p) => p.component), ['Scritto', 'Orale']);
    expect(first.proposals.first.average, '6,5');
    expect(first.proposals.first.grade, '7');
    expect(first.proposals.last.grade, '');
    expect(first.absences, '3');
    final second = periods.last.students.single;
    expect(second.proposals.single.component, 'Unico');
    expect(second.proposals.single.average, '8');
    expect(second.absences, '0');
  });
}
