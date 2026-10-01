import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/docente/data/docente_classes_parser.dart';

// Same structure as /cvv/app/default/gioprof_selezione.php, invented content.
const _page = '''
<table>
<tr><td colspan="16" class="page_head_icon"><form><input name="cerca"></form></td></tr>
<tr valign="top">
  <td colspan="4" class="open_sans_extrabold font_size_28">
    <a href="regclasse.php?classe_id=11&amp;gruppo_id=" title="Classe di esempio sezione B"> 3B </a>
  </td>
  <td colspan="10">
    <div>
      <p class="font_size_12"><font class="graytext"> CORSO DI PROVA</font></p>
      <p class="graytext">Codice: ABCD00000X</p>
    </div>
    <div class="font_size_10">
      <div><a href="regclasse.php?classe_id=11&amp;gruppo_id="><img><br> Registro </a></div>
      <div><a href="agenda.php?classe_id=11&amp;gruppo_id="><img><br> Agenda </a></div>
      <div><a href="gioprof_note.php?classe_id=11&amp;gruppo_id="><img><br> Note </a></div>
    </div>
  </td>
  <td colspan="34">
    <div class="materia_11_0">
      <div><div class="open_sans_condensed_bold font_size_10">FISICA</div></div>
      <div class="font_size_10">
        <div class="select_materia_over"><a href="gioprof.php?classe_id=11&amp;materia=7&amp;ope=RFF"><div><img><br> Lezioni </div></a></div>
        <div class="select_materia_over"><a href="regvoti.php?classe_id=11&amp;materia_id=7&amp;gruppo_id="><div><img><br> Valutazioni </div></a></div>
      </div>
    </div>
    <div class="materia_11_0">
      <div><div class="open_sans_condensed_bold font_size_10">EDUCAZIONE CIVICA</div></div>
      <div class="font_size_10">
        <div class="select_materia_over"><a href="regvoti.php?classe_id=11&amp;materia_id=8&amp;gruppo_id="><div><img><br> Valutazioni </div></a></div>
      </div>
    </div>
  </td>
</tr>
</table>
''';

void main() {
  test('parses classes, class links and subjects', () {
    final classes = parseDocenteClasses(_page);
    expect(classes, hasLength(1));
    final c = classes.single;
    expect(c.name, '3B');
    expect(c.description, 'Classe di esempio sezione B');
    expect(c.course, 'CORSO DI PROVA');
    expect(c.links.map((l) => l.page),
        ['regclasse.php', 'agenda.php', 'gioprof_note.php']);
    expect(c.linkTo('agenda.php')!.path,
        '/cvv/app/default/agenda.php?classe_id=11&gruppo_id=');
    expect(c.subjects.map((s) => s.name), ['FISICA', 'EDUCAZIONE CIVICA']);
    expect(c.subjects.first.linkTo('regvoti.php')!.label, 'Valutazioni');
    expect(c.subjects.first.linkTo('gioprof.php')!.path, contains('materia=7'));
    expect(c.linkTo('regassenze.php')!.path,
        '/cvv/app/default/regassenze.php?granular=m&classe_id=11&gruppo_id=');
  });

  test('ignores rows without a class link', () {
    expect(
        parseDocenteClasses('<table><tr><td>nulla</td></tr></table>'), isEmpty);
  });
}
