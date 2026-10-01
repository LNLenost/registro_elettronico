import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:registro_elettronico/feature/docente/data/docente_classes_parser.dart';
import 'package:registro_elettronico/feature/docente/data/docente_text.dart';

/// Parsers of the Spaggiari services reached from the teacher menu (Ver.Di,
/// PLS, forms, requests, signature book, votes). Each mirrors one web page.
/// What was verified on device is said per parser; the rest is EXPERIMENTAL
/// (the mapped account had no data in these services).

// ---------------------------------------------------------------- forms ---

class DocenteForm {
  final String code;
  final String title;
  final String section;

  const DocenteForm(
      {required this.code, required this.title, required this.section});
}

/// Forms of `/ber/app/default/compilazione_modulo.php` ("Moduli on-line"):
/// `div.titolo_modulo` per form with `span[codice_modulo]` (title) and a
/// "Mod: <code>" span, under `div.underline > h3` section headers. Verified.
List<DocenteForm> parseDocenteForms(String page) {
  final document = html.parse(page);
  final forms = <DocenteForm>[];
  var section = '';
  for (final element
      in document.querySelectorAll('div.underline, div.titolo_modulo')) {
    if (element.classes.contains('underline')) {
      section = docenteClean(element.text);
      continue;
    }
    final title = element.querySelector('span[codice_modulo]');
    if (title == null) continue;
    forms.add(DocenteForm(
      code: title.attributes['codice_modulo'] ?? '',
      title: docenteClean(title.text),
      section: section,
    ));
  }
  return forms;
}

// --------------------------------------------------------------- requests ---

class DocenteRequest {
  final String id;
  final String title;
  final String status;
  final String date;

  const DocenteRequest(
      {required this.id,
      required this.title,
      required this.status,
      required this.date});
}

/// The personal id the requests page sends with every query: it is inside
/// the page as `"id_anagrafe":{"id":"<n>"...}`. Verified.
String? parseDocenteRequestsOwner(String page) =>
    RegExp(r'"id_anagrafe"\s*:\s*\{\s*"id"\s*:\s*"?(\d+)')
        .firstMatch(page)
        ?.group(1);

/// `richieste.exec.php` (`ope=get`) answers `{error, result, html, data: []}`.
/// EXPERIMENTAL: the mapped account had no requests, so the fields of a
/// request are inferred (id, description/type, status, request date).
List<DocenteRequest> parseDocenteRequests(dynamic json) {
  if (json is String) json = jsonDecode(json);
  final data = json is Map ? json['data'] : null;
  if (data is! List) return const [];
  String pick(Map item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && '$value'.trim().isNotEmpty) {
        return docenteClean('$value');
      }
    }
    return '';
  }

  return [
    for (final item in data.whereType<Map>())
      DocenteRequest(
        id: pick(item, ['id', 'id_richiesta']),
        title: pick(item, [
          'descrizione',
          'tipo_richiesta',
          'tipo',
          'oggetto',
          'titolo',
          'causale'
        ]),
        status: pick(item, ['stato_richiesta', 'stato', 'stato_descrizione']),
        date: pick(item, ['data_richiesta', 'data', 'data_inserimento']),
      ),
  ];
}

// ------------------------------------------------------------- Ver.Di ---

class DocenteVerdiMeeting {
  final String title;
  final String date;
  final String place;

  const DocenteVerdiMeeting(
      {required this.title, required this.date, required this.place});
}

class DocenteVerdiMeetings {
  /// Meeting types offered by the page's filter (`select.filtro_tipo_evento`).
  final Map<String, String> types;
  final List<DocenteVerdiMeeting> meetings;

  const DocenteVerdiMeetings({required this.types, required this.meetings});
}

/// Personal meetings of Ver.Di (`/vrd/app/default/riunioni_pers.php`).
/// Verified: header (Evento / Data / Luogo) and filters. EXPERIMENTAL: the
/// rows are read as the table rows after the header row, three cells each.
DocenteVerdiMeetings parseDocenteVerdiMeetings(String page) {
  final document = html.parse(page);
  final types = <String, String>{};
  final filter = document
      .querySelectorAll('select')
      .where((s) => s.classes.contains('filtro_tipo_evento'));
  for (final option in filter.expand((s) => s.querySelectorAll('option'))) {
    final value = option.attributes['value'] ?? '';
    if (value.isNotEmpty) types[value] = docenteClean(option.text);
  }
  final meetings = <DocenteVerdiMeeting>[];
  final header = document
      .querySelectorAll('tr.open_sans_semibold')
      .where((r) => docenteClean(r.text).startsWith('Evento'))
      .toList();
  if (header.isNotEmpty) {
    for (Element? row = header.first.nextElementSibling;
        row != null;
        row = row.nextElementSibling) {
      final cells = row.children
          .where((c) => c.localName == 'td')
          .map((c) => docenteClean(c.text))
          .where((t) => t.isNotEmpty)
          .toList();
      if (cells.length < 2) continue;
      meetings.add(DocenteVerdiMeeting(
        title: cells[0],
        date: cells.length > 1 ? cells[1] : '',
        place: cells.length > 2 ? cells[2] : '',
      ));
    }
  }
  return DocenteVerdiMeetings(types: types, meetings: meetings);
}

// ------------------------------------------------------- signature book ---

class DocenteSignDocument {
  final String title;
  final String kind;
  final String date;

  const DocenteSignDocument(
      {required this.title, required this.kind, required this.date});
}

class DocenteSignBook {
  /// Signature types of the page's filter (Visto, Firma grafica, ...).
  final List<String> filters;
  final List<DocenteSignDocument> documents;

  const DocenteSignBook({required this.filters, required this.documents});
}

/// `/sdg/app/default/firma_anywhere.php`: the filters and the "NESSUN
/// DOCUMENTO DA FIRMARE" state are verified; EXPERIMENTAL: documents are read
/// as the elements with a `documento`/`document` class carrying text.
DocenteSignBook parseDocenteSignBook(String page) {
  final document = html.parse(page);
  final filters = [
    for (final option in document.querySelectorAll('select option'))
      docenteClean(option.text)
  ].where((t) => t.isNotEmpty).toList();
  final documents = <DocenteSignDocument>[];
  if (!document.body!.text.toUpperCase().contains('NESSUN DOCUMENTO')) {
    for (final element in document
        .querySelectorAll('[class*="documento"], [class*="doc-row"]')) {
      final lines = element.children
          .map((c) => docenteClean(c.text))
          .where((t) => t.isNotEmpty)
          .toList();
      if (lines.isEmpty) continue;
      documents.add(DocenteSignDocument(
        title: lines.first,
        kind: lines.length > 1 ? lines[1] : '',
        date: lines.length > 2 ? lines.last : '',
      ));
    }
  }
  return DocenteSignBook(filters: filters, documents: documents);
}

// ---------------------------------------------------------------- votes ---

/// Result of opening Eligo (`/home/app/default/eligoauth.php`): the service
/// answers with a title and a message when the account cannot log in.
class DocenteEligoState {
  final String title;
  final String message;
  final bool available;

  const DocenteEligoState(
      {required this.title, required this.message, required this.available});
}

/// Verified: on the mapped account the page is the error "Autenticazione
/// fallita ... Utente non ancora creato nella piattaforma Quorum".
DocenteEligoState parseDocenteEligo(String page) {
  final document = html.parse(page);
  final error = document.querySelector('.error-container');
  if (error != null) {
    return DocenteEligoState(
      title: docenteClean(error.querySelector('h2')?.text),
      message: [
        for (final p in error.querySelectorAll('p'))
          if (docenteClean(p.text).isNotEmpty) docenteClean(p.text)
      ].join('\n'),
      available: false,
    );
  }
  return DocenteEligoState(
      title: docenteClean(document.querySelector('title')?.text),
      message: '',
      available: true);
}

// ------------------------------------------------------------------ PLS ---

/// Classes of the PLS product (`/pdp/app/default/selezione_classi.php`): one
/// `a[href*=classe_id]` per class, opening `lista_studenti_pfi.php`. Verified.
List<DocenteLink> parseDocentePlsClasses(String page,
    {String base = '/pdp/app/default/selezione_classi.php'}) {
  final document = html.parse(page);
  final baseUri = Uri.parse(base);
  final seen = <String>{};
  final classes = <DocenteLink>[];
  for (final a in document.querySelectorAll('a[href*="classe_id="]')) {
    final uri = baseUri.resolve(a.attributes['href']!.trim());
    final path = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
    if (!seen.add(path)) continue;
    final label = docenteClean(a.text);
    if (label.isNotEmpty) classes.add(DocenteLink(label, path));
  }
  return classes;
}

class DocentePlsStudent {
  final String id;
  final String name;
  final String birth;

  const DocentePlsStudent(
      {required this.id, required this.name, required this.birth});
}

class DocentePlsClass {
  /// Page title, e.g. "Programmazione didattica della classe" + class.
  final String title;
  final List<DocentePlsStudent> students;

  const DocentePlsClass({required this.title, required this.students});
}

/// Students of a PLS class: `lista_studenti_pfi.php?classe_id=` (title
/// verified; the class had no student rows) and the statistics page
/// (`/cmp/app/default/statistiche.php`, `tr.row_stud[studente_id]` with name
/// and birth date, verified). EXPERIMENTAL for the class page: its rows are
/// read as elements carrying `studente_id`.
DocentePlsClass parseDocentePlsStudents(String page) {
  final document = html.parse(page);
  final title = [
    for (final span in document
        .querySelectorAll('span.page_title_fixed, span.page_title_variable'))
      docenteClean(span.text)
  ].where((t) => t.isNotEmpty).join(' ');
  final students = <DocentePlsStudent>[];
  final seen = <String>{};
  for (final row in document.querySelectorAll('[studente_id]')) {
    final id = row.attributes['studente_id'] ?? '';
    if (id.isEmpty || !seen.add(id)) continue;
    final paragraphs = row.querySelectorAll('p');
    final name = paragraphs.isNotEmpty
        ? docenteClean(paragraphs.first.text)
        : docenteClean(row.text);
    if (name.isEmpty) continue;
    students.add(DocentePlsStudent(
      id: id,
      name: name,
      birth: paragraphs.length > 1 ? docenteClean(paragraphs[1].text) : '',
    ));
  }
  return DocentePlsClass(title: title, students: students);
}

/// Documents of a student's PLS portfolio
/// (`/pdp/app/default/portfolio_studente.php?studente_id=`). EXPERIMENTAL:
/// the page is empty on the mapped account; documents are read as the links
/// of the page content that are not the back button or the search.
List<DocenteLink> parseDocentePortfolio(String page) {
  final document = html.parse(page);
  final base = Uri.parse('/pdp/app/default/portfolio_studente.php');
  final docs = <DocenteLink>[];
  for (final a in document.querySelectorAll('.main-wrapper a[href]')) {
    if (a.querySelector('.btn-back') != null) continue;
    final href = a.attributes['href']!.trim();
    final label = docenteClean(a.text);
    if (label.isEmpty ||
        href.startsWith('#') ||
        href.startsWith('javascript')) {
      continue;
    }
    final uri = base.resolve(href);
    docs.add(DocenteLink(
        label, uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path));
  }
  return docs;
}
