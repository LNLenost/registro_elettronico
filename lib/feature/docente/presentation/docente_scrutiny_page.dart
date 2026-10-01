import 'package:flutter/material.dart';
import 'package:registro_elettronico/core/presentation/widgets/cusotm_placeholder.dart';
import 'package:registro_elettronico/feature/docente/data/docente_classes_parser.dart';
import 'package:registro_elettronico/feature/docente/data/docente_scrutiny_parser.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_experimental.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_widgets.dart';
import 'package:registro_elettronico/feature/settings/widgets/header_text.dart';

/// Online scrutiny: the classes and subjects of the scrutiny, laid out as the
/// class page (accent headers, plain tiles); each subject opens its proposed
/// grades. Read only: proposing grades stays on the web register.
class DocenteScrutinyPage extends StatefulWidget {
  final String title;

  const DocenteScrutinyPage({Key? key, required this.title}) : super(key: key);

  @override
  _DocenteScrutinyPageState createState() => _DocenteScrutinyPageState();
}

class _DocenteScrutinyPageState extends State<DocenteScrutinyPage> {
  Future<List<DocenteClass>>? _classes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _classes ??= _fetch();
  }

  Future<List<DocenteClass>> _fetch() {
    final scope = DocenteScope.of(context);
    return scope.guard(scope.api
        .getPage(docenteScrutinyPath)
        .then(parseDocenteScrutinyClasses));
  }

  Future<void> _refresh() async {
    final future = _fetch();
    setState(() => _classes = future);
    await future.catchError((_) => <DocenteClass>[]);
  }

  @override
  Widget build(BuildContext context) {
    Widget header(String text) => Padding(
          padding: const EdgeInsets.only(top: 16, left: 16),
          child: HeaderText(text: text),
        );
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: DocenteAsyncView<List<DocenteClass>>(
        future: _classes,
        isEmpty: (classes) => classes.isEmpty,
        emptyText: docenteText(context, 'docente_classes_empty'),
        onRefresh: _refresh,
        builder: (classes) => ListView(
          children: [
            for (final docenteClass in classes) ...[
              header([docenteClass.name, docenteClass.course]
                  .where((s) => s.isNotEmpty)
                  .join(' · ')),
              for (final subject in docenteClass.subjects)
                for (final link in subject.links)
                  ListTile(
                    leading: const Icon(Icons.assignment_turned_in),
                    title: Text(subject.name),
                    subtitle: Text(link.label),
                    onTap: () => DocenteScope.push(
                      context,
                      DocenteProposalsPage(
                        link: link,
                        title: '${docenteClass.name} · ${subject.name}',
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Proposed grades of a class and subject, as the grades page: periods as
/// chips, one card per student with average and proposed grade of each
/// component, absences and notes.
class DocenteProposalsPage extends StatefulWidget {
  final DocenteLink link;
  final String title;

  const DocenteProposalsPage(
      {Key? key, required this.link, required this.title})
      : super(key: key);

  @override
  _DocenteProposalsPageState createState() => _DocenteProposalsPageState();
}

class _DocenteProposalsPageState extends State<DocenteProposalsPage> {
  Future<List<DocenteProposalsPeriod>>? _periods;
  int _period = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _periods ??= _fetch();
  }

  Future<List<DocenteProposalsPeriod>> _fetch() {
    final scope = DocenteScope.of(context);
    return scope.guard(scope.api
        .getPage(widget.link.path)
        .then(parseDocenteProposals)
        .then((p) {
      debugPrint(
          '[DocenteProposals] periods=${p.map((x) => '${x.id}:${x.students.length}').toList()}');
      return p;
    }));
  }

  Future<void> _refresh() async {
    final future = _fetch();
    setState(() => _periods = future);
    await future.catchError((_) => <DocenteProposalsPeriod>[]);
  }

  @override
  Widget build(BuildContext context) {
    final dash = docenteText(context, 'docente_proposal_none');
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: DocenteAsyncView<List<DocenteProposalsPeriod>>(
        future: _periods,
        isEmpty: (_) => false,
        emptyText: '',
        onRefresh: _refresh,
        builder: (periods) {
          final period = periods.isEmpty
              ? null
              : periods[_period.clamp(0, periods.length - 1)];
          return ListView(
            children: [
              DocenteExperimentalBanner(
                  title: widget.title, path: widget.link.path),
              if (periods.length > 1)
                DocenteChips(
                  labels: [for (final p in periods) p.name],
                  selected: _period,
                  onSelected: (i) => setState(() => _period = i),
                ),
              if (period == null || period.students.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: CustomPlaceHolder(
                    icon: Icons.assignment_turned_in,
                    text: docenteText(context, 'docente_proposals_empty'),
                    showUpdate: false,
                  ),
                )
              else
                Padding(
                  padding: docenteListPadding,
                  child: Column(children: [
                    for (final student in period.students)
                      DocenteCard(
                        title: student.name,
                        details: [
                          for (final p in student.proposals)
                            '${p.component}: '
                                '${docenteText(context, 'docente_average')} '
                                '${p.average.isNotEmpty ? p.average : dash} · '
                                'VP ${p.grade.isNotEmpty ? p.grade : dash}',
                          '${docenteText(context, 'docente_absences')}: '
                              '${student.absences.isNotEmpty ? student.absences : '0'}',
                          if (student.note.isNotEmpty) student.note,
                          if (student.recovery.isNotEmpty) student.recovery,
                        ],
                        trailing: DocenteBadge(
                          student.proposals.map((p) => p.grade).firstWhere(
                              (g) => g.isNotEmpty,
                              orElse: () => '-'),
                          student.proposals.any((p) => p.grade.isNotEmpty)
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.grey,
                        ),
                      ),
                  ]),
                ),
            ],
          );
        },
      ),
    );
  }
}
