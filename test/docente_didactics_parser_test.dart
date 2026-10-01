import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/docente/data/docente_didactics_parser.dart';

// Inferred: the mapped account had no materials in
// /cvv/app/default/didattica.php. The upload template is the real one and
// must be ignored.
const _page = '''
<div class="row_upload_contenuto tpl_clone_dpz"><input type="hidden" class="tipo_contenuto" value="0"></div>
<table>
<tr class="row_folder" folder_id="5"><td>Verifiche</td></tr>
<tr contenuto_id="50"><td><img src="/img/20/20_pdf.png">Esercizi 1</td><td>02-09-2026</td></tr>
<tr contenuto_id="51" tipo_contenuto="1"><td>Sito del corso</td></tr>
<tr class="row_folder" folder_id="6"><td>Appunti</td></tr>
<tr contenuto_id="60" tipo_contenuto="2"><td>Riassunto</td></tr>
</table>
''';

void main() {
  test('folders and contents in page order, template skipped', () {
    final folders = parseDocenteDidactics(_page);
    expect(folders.map((f) => f.name), ['Verifiche', 'Appunti']);
    expect(folders.first.materials.map((m) => m.name),
        ['Esercizi 1', 'Sito del corso']);
    expect(folders.first.materials.first.date, '02-09-2026');
    expect(folders.first.materials.first.kind, DocenteMaterialKind.file);
    expect(folders.first.materials.last.kind, DocenteMaterialKind.link);
    expect(folders.last.materials.single.kind, DocenteMaterialKind.text);
  });

  test('the empty page of the mapped account has no folders', () {
    expect(
        parseDocenteDidactics(
            '<div class="row_upload_contenuto tpl_clone_dpz"></div>'),
        isEmpty);
  });
}
