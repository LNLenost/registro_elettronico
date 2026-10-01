import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/docente/data/docente_class_directory_parser.dart';

// Same structure as /cvv/app/default/selezione_classi.php, invented content.
const _classes = '''
<table>
<tr class="griglia noprint"><td class="page_head_icon"><a href="selezione_gruppi.php"><img></a><p>Corsi</p></td></tr>
<tr align="center">
  <td colspan="4" class="font_size_22 redtext"><div> ITIS </div></td>
  <td colspan="7"><p class="font_size_12"><font class="bluetext">ELETTRONICA</font></p><p class="graytext">Plesso: ABCD00000X</p></td>
  <td colspan="7"><div class="rigtab"><a aria-label="Classe 3A" href="regclasse.php?classe_id=11&amp;quad="><div class="open_sans font_size_22"><div> 3A </div></div><div class="single"><span class="bluetext">ELETTRONICA - AUTOMAZIONE</span></div></a></div></td>
  <td colspan="7"><div class="rigtab"><a href="regclasse.php?classe_id=12&amp;quad="><div><div> 4A </div></div><div class="single"><span>ELETTRONICA</span></div></a></div></td>
  <td colspan="7"><div class="rigtab"><div>&nbsp;</div></div></td>
</tr>
</table>
''';

// Same structure as /cvv/app/default/selezione_gruppi.php, invented content.
const _groups = '''
<table>
<tr><td colspan="20"><p class="double"></p><p class="bluetext font_size_12"> 3A ELETTRONICA</p><p class="graytext font_size_10"> Plesso: ABCD00000X</p><p></p></td>
<td colspan="28"><p class="double"><a href="../../../cvv/app/default/regclasse.php?corsoextra=0&amp;gruppo_id=GR_LAB_1" title="GR_LAB_1 - Laboratorio di robotica"><font> GR_LAB_1 </font></a></p></td></tr>
</table>
''';

void main() {
  test('parses the all-classes directory', () {
    final groups = parseDocenteClassDirectory(_classes);
    expect(groups, hasLength(1));
    expect(groups.single.title, 'ITIS');
    expect(groups.single.subtitle, 'ELETTRONICA · Plesso: ABCD00000X');
    expect(groups.single.entries.map((e) => e.name), ['3A', '4A']);
    expect(groups.single.entries.first.subtitle, 'ELETTRONICA - AUTOMAZIONE');
    expect(groups.single.entries.first.register.path,
        '/cvv/app/default/regclasse.php?classe_id=11&quad=');
  });

  test('parses course groups and builds their class pages', () {
    final group = parseDocenteClassDirectory(_groups).single;
    expect(group.title, '3A ELETTRONICA');
    final entry = group.entries.single;
    expect(entry.name, 'GR_LAB_1');
    expect(entry.subtitle, 'Laboratorio di robotica');
    final docenteClass = entry.toClass();
    expect(docenteClass.linkTo('agenda.php')!.path,
        '/cvv/app/default/agenda.php?classe_id=&gruppo_id=GR_LAB_1');
    expect(docenteClass.linkTo('regclasse.php')!.path,
        contains('gruppo_id=GR_LAB_1'));
  });
}
