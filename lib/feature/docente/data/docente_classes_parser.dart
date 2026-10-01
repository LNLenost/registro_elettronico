import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:registro_elettronico/feature/docente/data/docente_text.dart';

/// A link from the teacher web area, with the path resolved against the page
/// it was found on (the web pages use relative links).
class DocenteLink {
  final String label;
  final String path;

  const DocenteLink(this.label, this.path);

  String get page => Uri.parse(path).pathSegments.last;
}

class DocenteSubject {
  final String name;
  final List<DocenteLink> links;

  const DocenteSubject({required this.name, required this.links});

  DocenteLink? linkTo(String page) {
    for (final link in links) {
      if (link.page == page) return link;
    }
    return null;
  }
}

class DocenteClass {
  final String name;
  final String description;
  final String course;
  final List<DocenteLink> links;
  final List<DocenteSubject> subjects;

  const DocenteClass({
    required this.name,
    required this.description,
    required this.course,
    required this.links,
    required this.subjects,
  });

  DocenteLink? linkTo(String page) {
    for (final link in links) {
      if (link.page == page) return link;
    }
    if (page == 'regassenze.php') return _absencesLink();
    if (page == 'didattica_distanza.php') return _distanceLink();
    return null;
  }

  /// Distance learning grid of the class: the web menu reaches it through a
  /// class picker, so it is built from the class of the register link.
  DocenteLink? _distanceLink() {
    final register = linkTo('regclasse.php');
    if (register == null) return null;
    final classId = Uri.parse(register.path).queryParameters['classe_id'];
    if (classId == null || classId.isEmpty) return null;
    return DocenteLink('DAD',
        '${_classesBase}didattica_distanza.php?classe_id=${Uri.encodeQueryComponent(classId)}');
  }

  /// The class list has no absences link (it is only inside the grades
  /// page): build it from the class and group of the register link.
  DocenteLink? _absencesLink() {
    final register = linkTo('regclasse.php');
    if (register == null) return null;
    final query = Uri.parse(register.path).queryParameters;
    String param(String name) =>
        '$name=${Uri.encodeQueryComponent(query[name] ?? '')}';
    return DocenteLink(
      'Assenze',
      // granular=m: the monthly view, as linked from the grades page.
      '${_classesBase}regassenze.php?granular=m&${param('classe_id')}&${param('gruppo_id')}',
    );
  }
}

const _classesBase = '/cvv/app/default/';

/// Parses "Le mie classi" (`/cvv/app/default/gioprof_selezione.php`): one table
/// row per class, with class-wide links and one `div.materia_*` per subject.
List<DocenteClass> parseDocenteClasses(String page) {
  final document = html.parse(page);
  final classes = <DocenteClass>[];
  for (final row in document.querySelectorAll('tr')) {
    final classLink = row.querySelector('td a[href^="regclasse.php"]');
    if (classLink == null || classLink.text.trim().isEmpty) continue;
    final subjectBlocks = row.querySelectorAll('div[class^="materia_"]');
    classes.add(DocenteClass(
      name: docenteClean(classLink.text),
      description: docenteClean(classLink.attributes['title']),
      course: docenteClean(row.querySelector('p.font_size_12')?.text),
      links: _links(row.querySelectorAll('a[href]').where(
            (a) => !subjectBlocks.any((block) => _contains(block, a)),
          )),
      subjects: [
        for (final block in subjectBlocks)
          DocenteSubject(
            name: docenteClean(
                block.querySelector('.open_sans_condensed_bold')?.text),
            links: _links(block.querySelectorAll('a[href]')),
          ),
      ],
    ));
  }
  return classes;
}

List<DocenteLink> _links(Iterable<Element> anchors) {
  final seen = <String>{};
  final links = <DocenteLink>[];
  for (final a in anchors) {
    final href = a.attributes['href'] ?? '';
    if (href.isEmpty || href.startsWith('#') || href.startsWith('javascript')) {
      continue;
    }
    final path = href.startsWith('/') ? href : '$_classesBase$href';
    final label = docenteClean(a.text);
    if (label.isEmpty || !seen.add(path)) continue;
    links.add(DocenteLink(label, path));
  }
  return links;
}

bool _contains(Element ancestor, Element node) {
  for (Element? e = node.parent; e != null; e = e.parent) {
    if (identical(e, ancestor)) return true;
  }
  return false;
}
