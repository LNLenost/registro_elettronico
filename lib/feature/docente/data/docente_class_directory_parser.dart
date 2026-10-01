import 'package:html/parser.dart' as html;
import 'package:registro_elettronico/feature/docente/data/docente_classes_parser.dart';
import 'package:registro_elettronico/feature/docente/data/docente_text.dart';

class DocenteDirectoryEntry {
  final String name;
  final String subtitle;
  final DocenteLink register;

  const DocenteDirectoryEntry(
      {required this.name, required this.subtitle, required this.register});

  /// A class/group opened from a directory has only its register link: the
  /// other class pages take the same `classe_id`/`gruppo_id`.
  DocenteClass toClass() {
    final query = Uri.parse(register.path).queryParameters;
    String page(String name, [String extra = '']) =>
        '/cvv/app/default/$name?classe_id=${Uri.encodeQueryComponent(query['classe_id'] ?? '')}'
        '&gruppo_id=${Uri.encodeQueryComponent(query['gruppo_id'] ?? '')}$extra';
    return DocenteClass(
      name: name,
      description: subtitle,
      course: '',
      links: [
        DocenteLink('Registro', register.path),
        DocenteLink('Agenda', page('agenda.php')),
        DocenteLink('Note', page('gioprof_note.php')),
      ],
      subjects: const [],
    );
  }
}

class DocenteDirectoryGroup {
  final String title;
  final String subtitle;
  final List<DocenteDirectoryEntry> entries;

  const DocenteDirectoryGroup(
      {required this.title, required this.subtitle, required this.entries});
}

/// Parses the class directories: "Tutte le classi"
/// (`/cvv/app/default/selezione_classi.php`, one row per course with a cell per
/// class) and "Corsi" (`/cvv/app/default/selezione_gruppi.php`, one row per
/// group). Each row: heading cells without links, then `regclasse.php` links.
List<DocenteDirectoryGroup> parseDocenteClassDirectory(String page) {
  final document = html.parse(page);
  final groups = <DocenteDirectoryGroup>[];
  for (final row in document.querySelectorAll('tr')) {
    final anchors = row.querySelectorAll('a[href*="regclasse.php"]');
    if (anchors.isEmpty) continue;
    final headingCells = row.children
        .where((td) => td.querySelector('a[href*="regclasse.php"]') == null)
        .toList();
    final headings = <String>[];
    for (final cell in headingCells) {
      final blocks = cell
          .querySelectorAll('div, p')
          .where((b) => b.querySelector('div, p') == null);
      for (final block in blocks.isEmpty ? [cell] : blocks) {
        final text = docenteClean(block.text);
        if (text.isNotEmpty && !headings.contains(text)) headings.add(text);
      }
    }
    final entries = <DocenteDirectoryEntry>[];
    final seen = <String>{};
    for (final a in anchors) {
      final path = _resolve(a.attributes['href']!);
      if (!seen.add(path)) continue;
      final name =
          docenteClean(a.querySelector('div div, div, font')?.text ?? a.text);
      final subtitle = docenteClean(a.querySelector('span')?.text ??
          _titleDescription(a.attributes['title']));
      entries.add(DocenteDirectoryEntry(
          name: name, subtitle: subtitle, register: DocenteLink(name, path)));
    }
    groups.add(DocenteDirectoryGroup(
      title: headings.isNotEmpty ? headings.first : '',
      subtitle: headings.skip(1).join(' · '),
      entries: entries,
    ));
  }
  return groups;
}

/// "GROUP_ID - Description": the part after the id.
String _titleDescription(String? title) {
  final text = docenteClean(title);
  final dash = text.indexOf(' - ');
  return dash < 0 ? '' : text.substring(dash + 3);
}

String _resolve(String href) {
  final uri = Uri.parse('https://web.spaggiari.eu/cvv/app/default/')
      .resolve(href.trim());
  return '${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}';
}
