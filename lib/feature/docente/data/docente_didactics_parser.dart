import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:registro_elettronico/feature/docente/data/docente_text.dart';

const docenteDidacticsPath = '/cvv/app/default/didattica.php';

/// Kind of a material, as the student didactics contents (file, link, text).
enum DocenteMaterialKind { file, link, text }

class DocenteMaterial {
  final String id;
  final String name;
  final String date;
  final DocenteMaterialKind kind;

  const DocenteMaterial(
      {required this.id,
      required this.name,
      required this.date,
      required this.kind});
}

class DocenteFolder {
  final String id;
  final String name;
  final List<DocenteMaterial> materials;

  const DocenteFolder(
      {required this.id, required this.name, required this.materials});
}

const _folderAttributes = ['folder_id', 'cartella_id', 'id_cartella'];
const _materialAttributes = ['contenuto_id', 'id_contenuto', 'content_id'];
final _date = RegExp(r'\b\d{2}[-/]\d{2}[-/]\d{4}\b');

/// EXPERIMENTAL, inferred: parses the teacher's didactic materials
/// (`/cvv/app/default/didattica.php`). The mapped account had no materials,
/// so only the empty page and its upload template are known (`tipo_contenuto`
/// 0-2 is read as file/link/text, the order of the page's messages). Folders and
/// contents are inferred from elements carrying a folder or content id, in
/// page order; contents before any folder go in a folder without name.
List<DocenteFolder> parseDocenteDidactics(String page) {
  final document = html.parse(page);
  final folders = <DocenteFolder>[];
  final seenMaterials = <String>{};
  DocenteFolder? current;
  for (final element in document.querySelectorAll('*')) {
    if (_inTemplate(element)) continue;
    final folderId = _attribute(element, _folderAttributes);
    final materialId = _attribute(element, _materialAttributes);
    if (materialId != null) {
      if (!seenMaterials.add(materialId)) continue;
      if (current == null) {
        current = DocenteFolder(id: '', name: '', materials: []);
        folders.add(current);
      }
      current.materials.add(DocenteMaterial(
        id: materialId,
        name: _name(element),
        date: _date.firstMatch(_text(element))?.group(0) ?? '',
        kind: _kind(element),
      ));
    } else if (folderId != null &&
        (current == null || current.id != folderId)) {
      final existing = folders.where((f) => f.id == folderId);
      current = existing.isNotEmpty
          ? existing.first
          : DocenteFolder(id: folderId, name: _name(element), materials: []);
      if (existing.isEmpty) folders.add(current);
    }
  }
  return folders
      .where((f) => f.materials.isNotEmpty || f.id.isNotEmpty)
      .toList();
}

String? _attribute(Element element, List<String> names) {
  for (final name in names) {
    final value = element.attributes[name]?.trim();
    if (value != null && value.isNotEmpty && value != '0') return value;
  }
  return null;
}

/// Upload rows are cloned from hidden templates (`tpl_clone*`).
bool _inTemplate(Element element) {
  for (Element? e = element; e != null; e = e.parent) {
    if (e.classes.any((c) => c.startsWith('tpl_clone')) ||
        e.classes.contains('row_upload_contenuto') ||
        e.id == 'scroll_menu') return true;
  }
  return false;
}

/// First line of the element's text without dates.
String _name(Element element) {
  final title = element.attributes['title'];
  if (title != null && docenteClean(title).isNotEmpty) {
    return docenteClean(title);
  }
  final text = docenteClean(_text(element).replaceAll(_date, ''));
  return text.length > 120 ? '${text.substring(0, 117)}...' : text;
}

/// Text of the element with its cells kept apart (`Element.text` joins
/// adjacent cells without spaces).
String _text(Element element) {
  final parts = <String>[];
  void walk(Node node) {
    if (node is Text) {
      parts.add(node.text);
    } else {
      node.nodes.forEach(walk);
    }
  }

  walk(element);
  return parts.join(' ');
}

DocenteMaterialKind _kind(Element element) {
  final type = element.querySelector('.tipo_contenuto')?.attributes['value'] ??
      element.attributes['tipo_contenuto'] ??
      element.attributes['tipo'];
  if (type == '1') return DocenteMaterialKind.link;
  if (type == '2') return DocenteMaterialKind.text;
  final icons = element
      .querySelectorAll('img')
      .map((i) => i.attributes['src']?.toLowerCase() ?? '')
      .join(' ');
  if (icons.contains('link')) return DocenteMaterialKind.link;
  if (icons.contains('testo') || icons.contains('text')) {
    return DocenteMaterialKind.text;
  }
  return DocenteMaterialKind.file;
}
