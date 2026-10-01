/// Sections of the ClasseViva teacher menu (menu_classevivadocente.php).
///
/// Sections with a native read-only screen set [native]. [external] sections
/// are separate Spaggiari products reached through single sign-on: they have
/// no register pages to read and open in their own official interface.
/// [experimental] native screens were inferred from the structure of pages
/// that had no data on the mapped account: they are shown as experimental and
/// not verified, with a link to the web page to check them.
enum DocenteNativeScreen {
  agenda,
  noticeboard,
  classes,
  directory,
  meetings,
  timetable,
  didactics,
  books,
  dad,
  scrutiny,
  verdi,
  votes,
  pls,
  apps,
  forms,
  requests,
}

class DocenteSection {
  /// Localization key: `<key>` is the title, `<key>_sub` the subtitle.
  final String key;
  final String path;
  final DocenteNativeScreen? native;
  final bool external;
  final bool experimental;

  /// Listed under "Spaggiari services" in the more page (the products of the
  /// teacher menu that are not register pages).
  final bool service;

  const DocenteSection(this.key, this.path,
      {this.native,
      this.external = false,
      this.experimental = false,
      this.service = false});

  String get subtitleKey => '${key}_sub';
}

const docenteSections = <DocenteSection>[
  DocenteSection('docente_section_agenda', '/acc/app/default/agenda.php',
      native: DocenteNativeScreen.agenda),
  DocenteSection(
      'docente_section_noticeboard', '/sif/app/default/bacheca_personale.php',
      native: DocenteNativeScreen.noticeboard),
  DocenteSection(
      'docente_section_my_classes', '/cvv/app/default/gioprof_selezione.php',
      native: DocenteNativeScreen.classes),
  DocenteSection(
      'docente_section_all_classes', '/cvv/app/default/selezione_classi.php',
      native: DocenteNativeScreen.directory),
  DocenteSection('docente_section_extra',
      '/cvv/app/default/selezione_gruppi.php?corsoextra=1',
      native: DocenteNativeScreen.directory),
  DocenteSection(
      'docente_section_timetable', '/cvv/app/default/orario_docente.php',
      native: DocenteNativeScreen.timetable, experimental: true),
  DocenteSection('docente_section_didactics', '/cvv/app/default/didattica.php',
      native: DocenteNativeScreen.didactics, experimental: true),
  DocenteSection(
      'docente_section_dad', '/cvv/app/default/didattica_distanza.php',
      native: DocenteNativeScreen.dad, experimental: true, service: true),
  DocenteSection(
      'docente_section_meetings', '/cvv/app/default/gioprof_colloqui.php',
      native: DocenteNativeScreen.meetings, experimental: true),
  DocenteSection('docente_section_books', '/ldt/app/default/libri_classi.php',
      native: DocenteNativeScreen.books, experimental: true),
  DocenteSection(
      'docente_section_scrutiny', '/sol/app/default/gioprof_scrutinionline.php',
      native: DocenteNativeScreen.scrutiny, service: true),
  DocenteSection('docente_section_verdi', '/home/app/default/menu_verdi.php',
      native: DocenteNativeScreen.verdi, experimental: true, service: true),
  DocenteSection('docente_section_votes', '/home/app/default/eligoauth.php',
      native: DocenteNativeScreen.votes, service: true),
  DocenteSection('docente_section_pls', '/home/app/default/menu_competenze.php',
      native: DocenteNativeScreen.pls, experimental: true, service: true),
  DocenteSection(
      'docente_section_apps', '/home/app/default/menu_scuoladelfuturo.php',
      native: DocenteNativeScreen.apps, service: true),
  DocenteSection(
      'docente_section_forms', '/ber/app/default/compilazione_modulo.php',
      native: DocenteNativeScreen.forms, service: true),
  DocenteSection(
      'docente_section_requests', '/ngs/app/default/richieste_utente_new.php',
      native: DocenteNativeScreen.requests, experimental: true, service: true),
];
