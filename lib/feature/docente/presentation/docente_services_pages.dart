import 'package:flutter/material.dart';
import 'package:registro_elettronico/core/presentation/widgets/cusotm_placeholder.dart';
import 'package:registro_elettronico/feature/docente/data/docente_classes_parser.dart';
import 'package:registro_elettronico/feature/docente/data/docente_services_parser.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_experimental.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_web_page.dart';

/// A tile of a service menu (Ver.Di, PLS, applications).
class DocenteHubEntry {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget Function(BuildContext context)? page;

  /// Set for services outside the register (own login and interface).
  final String? externalPath;

  const DocenteHubEntry({
    required this.icon,
    required this.title,
    this.subtitle,
    this.page,
    this.externalPath,
  });
}

/// Service menu, as the more page: plain tiles. Services that live outside
/// the register (own product, own login) open in the authenticated web view
/// and say so.
class DocenteHubPage extends StatelessWidget {
  final String title;
  final List<DocenteHubEntry> entries;

  const DocenteHubPage({Key? key, required this.title, required this.entries})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scope = DocenteScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        children: [
          for (final entry in entries)
            ListTile(
              leading: Icon(entry.icon),
              title: Text(entry.title),
              subtitle: entry.externalPath != null
                  ? Text(docenteText(context, 'docente_external_service'))
                  : entry.subtitle == null
                      ? null
                      : Text(entry.subtitle!),
              onTap: () => DocenteScope.push(
                context,
                entry.page != null
                    ? entry.page!(context)
                    : DocenteWebPage(
                        title: entry.title,
                        path: entry.externalPath!,
                        userAgent: scope.userAgent,
                        onSessionExpired: scope.onSessionExpired,
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shared shell of the service pages: loads [fetch] once, refreshes by pull,
/// shows the experimental banner when [experimental].
class _ServicePage<T> extends StatefulWidget {
  final String title;
  final String path;
  final Future<T> Function(DocenteScope scope) fetch;
  final bool Function(T) isEmpty;
  final String emptyText;
  final IconData emptyIcon;
  final bool experimental;
  final Widget Function(BuildContext context, T data) builder;

  const _ServicePage({
    Key? key,
    required this.title,
    required this.path,
    required this.fetch,
    required this.isEmpty,
    required this.emptyText,
    required this.emptyIcon,
    required this.experimental,
    required this.builder,
  }) : super(key: key);

  @override
  _ServicePageState<T> createState() => _ServicePageState<T>();
}

class _ServicePageState<T> extends State<_ServicePage<T>> {
  Future<T>? _data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data ??= _load();
  }

  Future<T> _load() {
    final scope = DocenteScope.of(context);
    return scope.guard(widget.fetch(scope));
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _data = future);
    await future.catchError((Object _) => null as dynamic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: DocenteAsyncView<T>(
        future: _data,
        isEmpty: (_) => false,
        emptyText: '',
        onRefresh: _refresh,
        builder: (data) => ListView(
          children: [
            if (widget.experimental)
              DocenteExperimentalBanner(title: widget.title, path: widget.path),
            if (widget.isEmpty(data))
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: CustomPlaceHolder(
                  icon: widget.emptyIcon,
                  text: widget.emptyText,
                  showUpdate: false,
                ),
              )
            else
              widget.builder(context, data),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ forms ---

/// Forms of the school ("Moduli on-line"): the list grouped by section, as
/// the didactics folders. Filling a form stays on the web register.
class DocenteFormsPage extends StatelessWidget {
  final String path;
  final String title;

  const DocenteFormsPage({Key? key, required this.path, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) => _ServicePage<List<DocenteForm>>(
        title: title,
        path: path,
        fetch: (scope) => scope.api.getPage(path).then(parseDocenteForms),
        isEmpty: (forms) => forms.isEmpty,
        emptyText: docenteText(context, 'docente_forms_empty'),
        emptyIcon: Icons.assignment,
        experimental: false,
        builder: (context, forms) {
          final sections = <String, List<DocenteForm>>{};
          for (final form in forms) {
            sections.putIfAbsent(form.section, () => []).add(form);
          }
          return Padding(
            padding: docenteListPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in sections.entries) ...[
                  if (entry.key.isNotEmpty) DocenteHeader(entry.key),
                  for (final form in entry.value)
                    DocenteCard(
                      leading: const Icon(Icons.assignment),
                      title: form.title,
                      details: ['Mod. ${form.code}'],
                    ),
                ],
              ],
            ),
          );
        },
      );
}

// --------------------------------------------------------------- requests ---

/// Own requests and communications: one card per request with status and
/// date. Read only: creating a request stays on the web service.
class DocenteRequestsPage extends StatelessWidget {
  final String path;
  final String title;

  const DocenteRequestsPage({Key? key, required this.path, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) => _ServicePage<List<DocenteRequest>>(
        title: title,
        path: path,
        fetch: (scope) async {
          final owner =
              parseDocenteRequestsOwner(await scope.api.getPage(path));
          if (owner == null) return const <DocenteRequest>[];
          final requests =
              parseDocenteRequests(await scope.api.getRequests(owner));
          debugPrint('[DocenteRequests] requests=${requests.length}');
          return requests;
        },
        isEmpty: (requests) => requests.isEmpty,
        emptyText: docenteText(context, 'docente_requests_empty'),
        emptyIcon: Icons.work_outline,
        experimental: true,
        builder: (context, requests) => Padding(
          padding: docenteListPadding,
          child: Column(children: [
            for (final request in requests)
              DocenteCard(
                leading: const Icon(Icons.work_outline),
                title: request.title.isNotEmpty ? request.title : request.id,
                details: [request.status, request.date],
              ),
          ]),
        ),
      );
}

// ---------------------------------------------------------------- Ver.Di ---

/// Personal meetings of Ver.Di (digital minutes).
class DocenteVerdiMeetingsPage extends StatelessWidget {
  final String title;

  const DocenteVerdiMeetingsPage({Key? key, required this.title})
      : super(key: key);

  static const path = '/vrd/app/default/riunioni_pers.php';

  @override
  Widget build(BuildContext context) => _ServicePage<DocenteVerdiMeetings>(
        title: title,
        path: path,
        fetch: (scope) =>
            scope.api.getPage(path).then(parseDocenteVerdiMeetings),
        isEmpty: (data) => data.meetings.isEmpty,
        emptyText: docenteText(context, 'docente_verdi_empty'),
        emptyIcon: Icons.description,
        experimental: true,
        builder: (context, data) => Padding(
          padding: docenteListPadding,
          child: Column(children: [
            for (final meeting in data.meetings)
              DocenteCard(
                leading: const Icon(Icons.description),
                title: meeting.title,
                details: [meeting.date, meeting.place],
              ),
          ]),
        ),
      );
}

/// Signature book: the documents waiting for the teacher's signature. Read
/// only: signing stays on the web service.
class DocenteSignBookPage extends StatelessWidget {
  final String title;

  const DocenteSignBookPage({Key? key, required this.title}) : super(key: key);

  static const path = '/sdg/app/default/firma_anywhere.php';

  @override
  Widget build(BuildContext context) => _ServicePage<DocenteSignBook>(
        title: title,
        path: path,
        fetch: (scope) => scope.api.getPage(path).then(parseDocenteSignBook),
        isEmpty: (data) => data.documents.isEmpty,
        emptyText: docenteText(context, 'docente_signbook_empty'),
        emptyIcon: Icons.edit,
        experimental: true,
        builder: (context, data) => Padding(
          padding: docenteListPadding,
          child: Column(children: [
            for (final document in data.documents)
              DocenteCard(
                leading: const Icon(Icons.edit),
                title: document.title,
                details: [document.kind, document.date],
              ),
          ]),
        ),
      );
}

// ------------------------------------------------------------------ votes ---

/// Votes (Eligo): shows the state the service answers with (on an account
/// that is not registered it says so instead of a ballot list).
class DocenteEligoPage extends StatelessWidget {
  final String path;
  final String title;

  const DocenteEligoPage({Key? key, required this.path, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) => _ServicePage<DocenteEligoState>(
        title: title,
        path: path,
        fetch: (scope) => scope.api.getPage(path).then(parseDocenteEligo),
        isEmpty: (state) => false,
        emptyText: '',
        emptyIcon: Icons.how_to_vote,
        experimental: false,
        builder: (context, state) => Padding(
          padding: docenteListPadding,
          child: DocenteCard(
            leading: Icon(state.available ? Icons.how_to_vote : Icons.info),
            title: state.title.isNotEmpty
                ? state.title
                : docenteText(context, 'docente_section_votes'),
            details: state.message.split('\n'),
          ),
        ),
      );
}

// -------------------------------------------------------------------- PLS ---

/// Classes of the PLS product; a class opens its students.
class DocentePlsClassesPage extends StatelessWidget {
  final String title;

  const DocentePlsClassesPage({Key? key, required this.title})
      : super(key: key);

  static const path = '/pdp/app/default/selezione_classi.php';

  @override
  Widget build(BuildContext context) => _ServicePage<List<DocenteLink>>(
        title: title,
        path: path,
        fetch: (scope) => scope.api.getPage(path).then(parseDocentePlsClasses),
        isEmpty: (classes) => classes.isEmpty,
        emptyText: docenteText(context, 'docente_classes_empty'),
        emptyIcon: Icons.class_,
        experimental: false,
        builder: (context, classes) => Column(children: [
          for (final link in classes)
            ListTile(
              leading: const Icon(Icons.class_),
              title: Text(link.label),
              onTap: () => DocenteScope.push(context,
                  DocentePlsClassPage(path: link.path, title: link.label)),
            ),
        ]),
      );
}

/// A class of PLS: the didactic programming page and its students.
class DocentePlsClassPage extends StatelessWidget {
  final String path;
  final String title;

  const DocentePlsClassPage({Key? key, required this.path, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) => _ServicePage<DocentePlsClass>(
        title: title,
        path: path,
        fetch: (scope) => scope.api.getPage(path).then(parseDocentePlsStudents),
        isEmpty: (data) => data.students.isEmpty,
        emptyText: docenteText(context, 'docente_pls_empty'),
        emptyIcon: Icons.architecture,
        experimental: true,
        builder: (context, data) => Padding(
          padding: docenteListPadding,
          child: Column(children: [
            for (final student in data.students)
              DocenteCard(
                leading: const Icon(Icons.person),
                title: student.name,
                details: [student.birth],
                onTap: () => DocenteScope.push(
                  context,
                  DocentePortfolioPage(
                      studentId: student.id, title: student.name),
                ),
              ),
          ]),
        ),
      );
}

/// Student list of the PLS statistics page (every student of the teacher).
class DocentePlsStatsPage extends StatelessWidget {
  final String title;

  const DocentePlsStatsPage({Key? key, required this.title}) : super(key: key);

  static const path = '/cmp/app/default/statistiche.php';

  @override
  Widget build(BuildContext context) => _ServicePage<DocentePlsClass>(
        title: title,
        path: path,
        fetch: (scope) => scope.api.getPage(path).then(parseDocentePlsStudents),
        isEmpty: (data) => data.students.isEmpty,
        emptyText: docenteText(context, 'docente_pls_empty'),
        emptyIcon: Icons.insert_chart,
        // Names are verified; the per-student charts are drawn by the page's
        // script and are not read.
        experimental: true,
        builder: (context, data) => Padding(
          padding: docenteListPadding,
          child: Column(children: [
            for (final student in data.students)
              DocenteCard(
                leading: const Icon(Icons.insert_chart),
                title: student.name,
                details: [student.birth],
              ),
          ]),
        ),
      );
}

/// Portfolio of a student: the documents the page lists.
class DocentePortfolioPage extends StatelessWidget {
  final String studentId;
  final String title;

  const DocentePortfolioPage(
      {Key? key, required this.studentId, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final path =
        '/pdp/app/default/portfolio_studente.php?studente_id=${Uri.encodeQueryComponent(studentId)}';
    return _ServicePage<List<DocenteLink>>(
      title: title,
      path: path,
      fetch: (scope) => scope.api.getPage(path).then(parseDocentePortfolio),
      isEmpty: (docs) => docs.isEmpty,
      emptyText: docenteText(context, 'docente_portfolio_empty'),
      emptyIcon: Icons.folder_shared,
      experimental: true,
      builder: (context, docs) => Column(children: [
        for (final doc in docs)
          ListTile(
              leading: const Icon(Icons.description), title: Text(doc.label)),
      ]),
    );
  }
}
