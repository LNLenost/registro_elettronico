import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/docente/data/docente_notes_parser.dart';

// Grid as in /cvv/app/default/gioprof_note.php (structure of the mapped
// grid; what a cell with a note holds is inferred).
const _page = '''
<table id="data_table"><tbody>
<tr>
  <td id="eventi_multipli"></td>
  <td colspan="4"><input type="checkbox" id="seleziona_tutti"></td>
  <td colspan="3"></td>
  <td><a href="regclasse.php?classe_id=1&amp;data_start=2026-09-28">Lun<br>28<br>Set</a></td>
</tr>
<tr class="griglia_sep_gray">
  <td><div><input class="rowcheck" type="checkbox" name="check_studente[11]" value="11"> 1</div></td>
  <td colspan="7" class="griglia_sep_gray align_middle elenco_studenti" gruppo_id="" studente_id="11">
    <div><span></span>&nbsp; Rossi Anna</div><div class="open_sans font_size_8">&nbsp; 01-01-2010</div>
  </td>
  <td align="right" gruppo_id="" studente_id="11" evento_data="2026-09-28">
    <div class="myCorner"><img class="notaregistro" studente_id="11" evento_data="2026-09-28" src="../../../img/Nota_alunno-01.png" alt="N"></div>
  </td>
  <td>&nbsp;</td>
</tr>
<tr class="griglia_sep_gray">
  <td><div><input class="rowcheck" type="checkbox" name="check_studente[12]" value="12"> 2</div></td>
  <td colspan="7" class="griglia_sep_gray align_middle elenco_studenti" gruppo_id="" studente_id="12">
    <div><span></span>&nbsp; Bianchi Luca</div><div class="open_sans font_size_8">&nbsp; 02-02-2010</div>
  </td>
  <td align="center" evento_id="" gruppo_id="" studente_id="12" evento_data="2026-09-28"><div class="myCorner">&nbsp;</div></td>
  <td>&nbsp;</td>
</tr>
</tbody></table>
''';

void main() {
  test('reads students, grid dates and the cells with a note', () {
    final grid = parseDocenteNotes(_page);
    expect(grid.students, 2);
    expect(grid.dates, ['2026-09-28']);
    expect(grid.notes, hasLength(1));
    final note = grid.notes.single;
    expect(note.student, 'Rossi Anna');
    expect(note.studentId, '11');
    expect(note.day, DateTime(2026, 9, 28));
    expect(note.kind, DocenteNoteKind.disciplinary);
  });

  test('a grid without note icons or event ids has no notes', () {
    final grid = parseDocenteNotes(
        _page.replaceAll(RegExp(r'<img class="notaregistro"[^>]*>'), ''));
    expect(grid.students, 2);
    expect(grid.notes, isEmpty);
  });
}
