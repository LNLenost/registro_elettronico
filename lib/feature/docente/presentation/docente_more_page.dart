import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/feature/docente/domain/docente_sections.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_experimental.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_service_router.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_web_page.dart';
import 'package:registro_elettronico/feature/settings/settings_page.dart';
import 'package:registro_elettronico/feature/settings/widgets/header_text.dart';

/// "More" tab, as the student more page (feature/navigator/more_page.dart):
/// plain tiles under "general" (the teacher sections), the Spaggiari
/// services, and "other" (settings, change register, logout).
class DocenteMorePage extends StatelessWidget {
  const DocenteMorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    final scope = DocenteScope.of(context);
    Widget header(String text) => Padding(
          padding: const EdgeInsets.only(top: 16, left: 16),
          child: HeaderText(text: text),
        );
    Widget tile(DocenteSection section, VoidCallback? onTap,
            {String? subtitle}) =>
        ListTile(
          leading:
              Icon(docenteSectionIcons[section.key] ?? Icons.chevron_right),
          title: Text(docenteText(context, section.key)),
          subtitle: section.experimental
              ? const DocenteExperimentalLabel()
              : subtitle == null
                  ? null
                  : Text(subtitle),
          enabled: onTap != null,
          onTap: onTap,
        );
    void openWeb(DocenteSection section) => DocenteScope.push(
          context,
          DocenteWebPage(
            title: docenteText(context, section.key),
            path: section.path,
            userAgent: scope.userAgent,
            onSessionExpired: scope.onSessionExpired,
          ),
        );
    VoidCallback? action(DocenteSection section) {
      switch (section.native) {
        case DocenteNativeScreen.classes:
          return () => scope.openTab(DocenteTab.classes, classesChip: 0);
        case DocenteNativeScreen.directory:
          return () => scope.openTab(DocenteTab.classes,
              classesChip:
                  section.key == 'docente_section_all_classes' ? 1 : 2);
        case DocenteNativeScreen.meetings:
        case DocenteNativeScreen.timetable:
        case DocenteNativeScreen.didactics:
        case DocenteNativeScreen.books:
        case DocenteNativeScreen.dad:
        case DocenteNativeScreen.scrutiny:
        case DocenteNativeScreen.verdi:
        case DocenteNativeScreen.votes:
        case DocenteNativeScreen.pls:
        case DocenteNativeScreen.apps:
        case DocenteNativeScreen.forms:
        case DocenteNativeScreen.requests:
          return () => DocenteScope.push(
              context, docenteSectionScreen(context, section)!);
        case DocenteNativeScreen.agenda:
          return () => scope.openTab(DocenteTab.agenda);
        case DocenteNativeScreen.noticeboard:
          return () => scope.openTab(DocenteTab.noticeboard);
        case null:
          if (section.external) return () => openWeb(section);
          // Still to map: debug builds can open the web page.
          return kDebugMode ? () => openWeb(section) : null;
      }
    }

    // Sections that already have a bottom bar tab are not repeated here.
    const tabs = {
      DocenteNativeScreen.agenda,
      DocenteNativeScreen.noticeboard,
      DocenteNativeScreen.classes
    };
    final general = docenteSections
        .where((s) => !s.service && !tabs.contains(s.native))
        .toList();
    final services = docenteSections.where((s) => s.service).toList();
    return Scaffold(
      appBar: AppBar(title: Text(trans.translate('more_page')!)),
      body: ListView(
        children: [
          header(trans.translate('general')!),
          for (final section in general)
            tile(section, action(section),
                subtitle: section.native == null
                    ? docenteText(context, 'docente_coming_soon')
                    : null),
          header(docenteText(context, 'docente_external_services')),
          for (final section in services) tile(section, action(section)),
          header(trans.translate('other_section')!),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(trans.translate('settings')!),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const SettingsPage(teacher: true))),
          ),
          ListTile(
            leading: const Icon(Icons.supervisor_account),
            title: Text(docenteText(context, 'docente_change_registry')),
            onTap: scope.changeRegistry,
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(trans.translate('logout')!),
            onTap: () => showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: Text(trans.translate('logout_message_title')!),
                content: Text(trans.translate('logout_message')!),
                actions: [
                  TextButton(
                      child: Text(trans.translate('no')!),
                      onPressed: () => Navigator.pop(dialogContext)),
                  TextButton(
                    child: Text(trans.translate('yes')!),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      scope.logout();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Icons of the teacher sections (student more page uses Material icons too).
const docenteSectionIcons = {
  'docente_section_agenda': Icons.today,
  'docente_section_noticeboard': Icons.email,
  'docente_section_my_classes': Icons.class_,
  'docente_section_all_classes': Icons.view_module,
  'docente_section_extra': Icons.groups,
  'docente_section_timetable': Icons.access_time,
  'docente_section_didactics': Icons.folder,
  'docente_section_dad': Icons.laptop,
  'docente_section_meetings': Icons.people,
  'docente_section_books': Icons.menu_book,
  'docente_section_scrutiny': Icons.import_contacts,
  'docente_section_verdi': Icons.description,
  'docente_section_votes': Icons.how_to_vote,
  'docente_section_pls': Icons.architecture,
  'docente_section_apps': Icons.apps,
  'docente_section_forms': Icons.assignment,
  'docente_section_requests': Icons.work_outline,
};
