import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:registro_elettronico/feature/docente/data/docente_classes_parser.dart';
import 'package:registro_elettronico/feature/docente/data/docente_text.dart';

const docenteBooksPath = '/ldt/app/default/libri_classi.php';

class DocenteBook {
  final String isbn;
  final String title;
  final String subject;
  final String author;
  final String publisher;
  final String price;

  /// Flags of the adoption columns ("da acquistare", "consigliato", "nuova
  /// adozione"), by column title, for the cells that are marked.
  final List<String> flags;

  const DocenteBook({
    required this.isbn,
    required this.title,
    required this.subject,
    required this.author,
    required this.publisher,
    required this.price,
    required this.flags,
  });
}

/// EXPERIMENTAL, inferred: classes listed by the textbook adoptions page
/// (`/ldt/app/default/libri_classi.php`, title "Lista Classi"). The mapped
/// account had no classes there, so a class is inferred as any link of the
/// page content carrying a `classe_id`.
List<DocenteLink> parseDocenteBookClasses(String page,
    {String base = docenteBooksPath}) {
  final document = html.parse(page);
  final baseUri = Uri.parse(base);
  final seen = <String>{};
  final classes = <DocenteLink>[];
  for (final link in document.querySelectorAll('a[href*="classe_id="]')) {
    // Header and footer menus are not part of the list.
    if (_inChrome(link)) continue;
    final href = link.attributes['href']!.trim();
    final uri = baseUri.resolve(href);
    final path = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
    if (!seen.add(path)) continue;
    final row = _closest(link, 'tr');
    final label = docenteClean(link.text).isNotEmpty
        ? docenteClean(link.text)
        : docenteClean(row?.text);
    if (label.isNotEmpty) classes.add(DocenteLink(label, path));
  }
  return classes;
}

final _isbn = RegExp(r'\b(97[89][\d-]{10,14})\b');

/// EXPERIMENTAL, inferred: books of a class in the adoptions pages. Rows are
/// recognised by an ISBN (978/979 + 10 digits); the columns are named by the
/// nearest header row above them, matched on the usual adoption titles.
List<DocenteBook> parseDocenteBooks(String page) {
  final document = html.parse(page);
  final books = <DocenteBook>[];
  for (final table in document.querySelectorAll('table')) {
    var header = <String>[];
    for (final row in table.querySelectorAll('tr')) {
      // Only the rows of this table, not of tables nested in its cells.
      if (_closest(row, 'table') != table) continue;
      final cells = row.children
          .where((c) => c.localName == 'td' || c.localName == 'th')
          .toList();
      final texts = [for (final c in cells) docenteClean(c.text)];
      final isbnCell = texts.indexWhere(
          (t) => _isbn.hasMatch(t.replaceAll(' ', '')) && t.length <= 20);
      if (isbnCell < 0) {
        if (texts.any((t) => _column(t) != null)) header = texts;
        continue;
      }
      String at(String column) {
        final i = header.indexWhere((h) => _column(h) == column);
        return i >= 0 && i < texts.length ? texts[i] : '';
      }

      final flags = <String>[
        for (var i = 0; i < header.length && i < cells.length; i++)
          if (_column(header[i]) == 'flag' && _marked(cells[i], texts[i]))
            header[i]
      ];
      final title = at('title').isNotEmpty
          ? at('title')
          : (texts.toList()..sort((a, b) => b.length.compareTo(a.length)))
              .first;
      books.add(DocenteBook(
        isbn: _isbn.firstMatch(texts[isbnCell].replaceAll(' ', ''))!.group(1)!,
        title: title,
        subject: at('subject'),
        author: at('author'),
        publisher: at('publisher'),
        price: at('price'),
        flags: flags,
      ));
    }
  }
  return books;
}

String? _column(String title) {
  final t = title.toLowerCase();
  if (t.isEmpty || t.length > 40) return null;
  if (t.contains('isbn') || t.contains('codice')) return 'isbn';
  if (t.contains('titolo')) return 'title';
  if (t.contains('materia') || t.contains('disciplina')) return 'subject';
  if (t.contains('autor')) return 'author';
  if (t.contains('editor')) return 'publisher';
  if (t.contains('prezzo')) return 'price';
  if (t.contains('acquist') ||
      t.contains('consigl') ||
      t.contains('nuova') ||
      t.contains('adott') ||
      t.contains('in uso')) return 'flag';
  return null;
}

/// A flag cell is marked by a word (Sì/X) or by a checked icon or box.
bool _marked(Element cell, String text) {
  final t = text.toLowerCase();
  if (t == 'si' || t == 'sì' || t == 'x' || t == 's') return true;
  if (cell.querySelector('input[checked]') != null) return true;
  final icon = cell.querySelector('img');
  final src = icon?.attributes['src']?.toLowerCase() ?? '';
  return src.contains('check') || src.contains('ok') || src.contains('si.');
}

bool _inChrome(Element element) {
  for (Element? e = element; e != null; e = e.parent) {
    final c = e.classes;
    if (c.contains('page-header') ||
        c.contains('footer_menu') ||
        e.id == 'footer_menu' ||
        c.contains('page_head_icon')) return true;
  }
  return false;
}

Element? _closest(Element element, String tag) {
  for (var e = element.parent; e != null; e = e.parent) {
    if (e.localName == tag) return e;
  }
  return null;
}
