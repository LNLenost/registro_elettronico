import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:registro_elettronico/feature/docente/data/docente_classes_parser.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_absences_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_class_agenda_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_dad_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_experimental.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_grades_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_journal_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_notes_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_register_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_web_page.dart';
import 'package:registro_elettronico/feature/settings/widgets/header_text.dart';

/// Builds the native read-only screen for a web page of a class.
typedef DocenteLinkScreenBuilder = Widget Function(
    DocenteLink link, String title);

/// Native screens by web page name; pages missing here are "in arrivo".
final docenteLinkScreens = <String, DocenteLinkScreenBuilder>{
  'regclasse.php': (link, title) =>
      DocenteRegisterPage(link: link, title: title),
  'regvoti.php': (link, title) => DocenteGradesPage(link: link, title: title),
  'regassenze.php': (link, title) =>
      DocenteAbsencesPage(link: link, title: title),
  'agenda.php': (link, title) =>
      DocenteClassAgendaPage(link: link, title: title),
  'gioprof.php': (link, title) => DocenteJournalPage(link: link, title: title),
  'gioprof_note.php': (link, title) =>
      DocenteNotesPage(link: link, title: title),
  'didattica_distanza.php': (link, title) =>
      DocenteDadPage(link: link, title: title),
};

/// Native screens inferred from pages without data on the mapped account:
/// labelled experimental and not verified.
const docenteExperimentalPages = {'gioprof_note.php', 'didattica_distanza.php'};

/// A page of a class: web page name, title key and icon.
class _ClassPageEntry {
  final String page;
  final String titleKey;
  final IconData icon;

  const _ClassPageEntry(this.page, this.titleKey, this.icon);
}

// Icons as the matching entries of the student more page.
const _classPages = [
  _ClassPageEntry(
      'regclasse.php', 'docente_class_register', Icons.library_books),
  _ClassPageEntry('regassenze.php', 'docente_absences', Icons.assessment),
  _ClassPageEntry('agenda.php', 'docente_class_agenda', Icons.today),
  _ClassPageEntry('gioprof_note.php', 'docente_notes', Icons.info),
  _ClassPageEntry('didattica_distanza.php', 'docente_dad', Icons.laptop),
];

const _subjectPages = [
  _ClassPageEntry('gioprof.php', 'docente_journal', Icons.library_books),
  _ClassPageEntry('regvoti.php', 'docente_grades', Icons.class_),
];

/// Class menu, laid out as the student more page: plain tiles grouped under
/// accent headers (the class, then one group per subject).
class DocenteClassPage extends StatelessWidget {
  final DocenteClass docenteClass;

  const DocenteClassPage({Key? key, required this.docenteClass})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget header(String text) => Padding(
          padding: const EdgeInsets.only(top: 16, left: 16),
          child: HeaderText(text: text),
        );
    Widget pageTile(DocenteLink? link, _ClassPageEntry page) => link == null
        ? const SizedBox.shrink()
        : _LinkTile(
            link: link,
            title: docenteText(context, page.titleKey),
            icon: page.icon);
    final classInfo = [docenteClass.course, docenteClass.description]
        .where((s) => s.isNotEmpty)
        .join(' · ');
    return Scaffold(
      appBar: AppBar(title: Text(docenteClass.name)),
      body: ListView(
        children: [
          header(classInfo.isNotEmpty ? classInfo : docenteClass.name),
          for (final page in _classPages)
            pageTile(docenteClass.linkTo(page.page), page),
          for (final subject in docenteClass.subjects) ...[
            header(subject.name),
            for (final page in _subjectPages)
              pageTile(subject.linkTo(page.page), page),
          ],
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final DocenteLink link;
  final String title;
  final IconData icon;

  const _LinkTile(
      {required this.link, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final screen = docenteLinkScreens[link.page];
    final scope = DocenteScope.of(context);
    VoidCallback? onTap;
    if (screen != null) {
      onTap = () => DocenteScope.push(context, screen(link, title));
    } else if (kDebugMode) {
      // Debug builds only: opens the web page to map it into a native screen.
      onTap = () => DocenteScope.push(
            context,
            DocenteWebPage(
                title: title,
                path: link.path,
                userAgent: scope.userAgent,
                onSessionExpired: scope.onSessionExpired),
          );
    }
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: screen == null
          ? Text(docenteText(context, 'docente_coming_soon'))
          : docenteExperimentalPages.contains(link.page)
              ? const DocenteExperimentalLabel()
              : null,
      enabled: onTap != null,
      onTap: onTap,
    );
  }
}
