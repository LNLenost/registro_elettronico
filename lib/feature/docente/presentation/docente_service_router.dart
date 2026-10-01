import 'package:flutter/material.dart';
import 'package:registro_elettronico/feature/docente/domain/docente_sections.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_books_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_dad_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_didactics_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_meetings_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scrutiny_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_services_pages.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_timetable_page.dart';

/// The native screen of a section that opens as a page (not as a tab of the
/// bottom bar); null for the sections that are tabs.
Widget? docenteSectionScreen(BuildContext context, DocenteSection section) {
  final title = docenteText(context, section.key);
  final path = section.path;
  switch (section.native) {
    case DocenteNativeScreen.meetings:
      return DocenteMeetingsPage(path: path, title: title);
    case DocenteNativeScreen.timetable:
      return DocenteTimetablePage(path: path, title: title);
    case DocenteNativeScreen.didactics:
      return DocenteDidacticsPage(path: path, title: title);
    case DocenteNativeScreen.books:
      return DocenteBooksPage(path: path, title: title);
    case DocenteNativeScreen.dad:
      return DocenteDadClassesPage(title: title);
    case DocenteNativeScreen.scrutiny:
      return DocenteScrutinyPage(title: title);
    case DocenteNativeScreen.forms:
      return DocenteFormsPage(path: path, title: title);
    case DocenteNativeScreen.requests:
      return DocenteRequestsPage(path: path, title: title);
    case DocenteNativeScreen.votes:
      return DocenteEligoPage(path: path, title: title);
    case DocenteNativeScreen.verdi:
      return DocenteHubPage(title: title, entries: [
        DocenteHubEntry(
          icon: Icons.description,
          title: docenteText(context, 'docente_verdi_meetings'),
          subtitle: docenteText(context, 'docente_verdi_meetings_sub'),
          page: (c) => DocenteVerdiMeetingsPage(
              title: docenteText(c, 'docente_verdi_meetings')),
        ),
        _signBookEntry(context),
      ]);
    case DocenteNativeScreen.pls:
      return _plsHub(context, title);
    case DocenteNativeScreen.apps:
      return DocenteHubPage(title: title, entries: [
        DocenteHubEntry(
          icon: Icons.architecture,
          title: docenteText(context, 'docente_section_pls'),
          subtitle: docenteText(context, 'docente_app_pls_sub'),
          page: (c) => _plsHub(c, docenteText(c, 'docente_section_pls')),
        ),
        DocenteHubEntry(
          icon: Icons.business_center,
          title: docenteText(context, 'docente_app_ngs'),
          externalPath: '/ngs/',
        ),
        DocenteHubEntry(
          icon: Icons.school,
          title: docenteText(context, 'docente_app_learning'),
          externalPath: '/f4s_web/',
        ),
      ]);
    case DocenteNativeScreen.agenda:
    case DocenteNativeScreen.noticeboard:
    case DocenteNativeScreen.classes:
    case DocenteNativeScreen.directory:
    case null:
      return null;
  }
}

Widget _plsHub(BuildContext context, String title) =>
    DocenteHubPage(title: title, entries: [
      DocenteHubEntry(
        icon: Icons.architecture,
        title: docenteText(context, 'docente_pls_compile'),
        subtitle: docenteText(context, 'docente_pls_compile_sub'),
        page: (c) =>
            DocentePlsClassesPage(title: docenteText(c, 'docente_pls_compile')),
      ),
      DocenteHubEntry(
        icon: Icons.insert_chart,
        title: docenteText(context, 'docente_pls_stats'),
        subtitle: docenteText(context, 'docente_pls_stats_sub'),
        page: (c) =>
            DocentePlsStatsPage(title: docenteText(c, 'docente_pls_stats')),
      ),
      DocenteHubEntry(
        icon: Icons.folder_shared,
        title: docenteText(context, 'docente_pls_portfolio'),
        subtitle: docenteText(context, 'docente_pls_portfolio_sub'),
        page: (c) => DocentePlsClassesPage(
            title: docenteText(c, 'docente_pls_portfolio')),
      ),
      _signBookEntry(context),
    ]);

DocenteHubEntry _signBookEntry(BuildContext context) => DocenteHubEntry(
      icon: Icons.edit,
      title: docenteText(context, 'docente_signbook'),
      subtitle: docenteText(context, 'docente_signbook_sub'),
      page: (c) =>
          DocenteSignBookPage(title: docenteText(c, 'docente_signbook')),
    );
