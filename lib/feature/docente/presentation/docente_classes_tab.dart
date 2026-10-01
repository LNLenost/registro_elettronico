import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/core/presentation/widgets/cusotm_placeholder.dart';
import 'package:registro_elettronico/feature/docente/data/docente_class_directory_parser.dart';
import 'package:registro_elettronico/feature/docente/data/docente_classes_parser.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_class_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_navigator_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_widgets.dart';
import 'package:registro_elettronico/feature/settings/widgets/header_text.dart';

const docenteMyClassesPath = '/cvv/app/default/gioprof_selezione.php';
const _allClassesPath = '/cvv/app/default/selezione_classi.php';
const _coursesPath = '/cvv/app/default/selezione_gruppi.php?corsoextra=1';

/// Classes tab, in the place and layout of the student grades page: a chips
/// row (my classes / all classes / extracurricular) and cards with a round
/// indicator, as the subject cards of the grades periods.
class DocenteClassesTab extends StatefulWidget {
  const DocenteClassesTab({Key? key}) : super(key: key);

  @override
  DocenteClassesTabState createState() => DocenteClassesTabState();
}

class DocenteClassesTabState extends State<DocenteClassesTab> {
  int _chip = 0;
  Future<List<DocenteClass>>? _mine;
  final _directories = <int, Future<List<DocenteDirectoryGroup>>>{};

  void selectChip(int chip) => setState(() => _chip = chip);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mine ??= _fetchMine();
  }

  Future<List<DocenteClass>> _fetchMine() {
    final scope = DocenteScope.of(context);
    return scope.guard(
        scope.api.getPage(docenteMyClassesPath).then(parseDocenteClasses));
  }

  Future<List<DocenteDirectoryGroup>> _directory(int chip) =>
      _directories.putIfAbsent(chip, () {
        final scope = DocenteScope.of(context);
        return scope.guard(scope.api
            .getPage(chip == 1 ? _allClassesPath : _coursesPath)
            .then((page) {
          final groups = parseDocenteClassDirectory(page);
          debugPrint(
              '[DocenteDirectory] groups=${groups.length} entries=${groups.fold<int>(0, (n, g) => n + g.entries.length)}');
          return groups;
        }));
      });

  Future<void> _refresh() async {
    if (_chip == 0) {
      final future = _fetchMine();
      setState(() => _mine = future);
      await future.catchError((_) => <DocenteClass>[]);
    } else {
      // Drop the cached result; a failed one must not fail the refresh.
      unawaited(_directories
              .remove(_chip)
              ?.catchError((_) => <DocenteDirectoryGroup>[]) ??
          Future.value());
      final future = _directory(_chip);
      setState(() {});
      await future.catchError((_) => <DocenteDirectoryGroup>[]);
    }
  }

  void _open(DocenteClass docenteClass) =>
      DocenteScope.push(context, DocenteClassPage(docenteClass: docenteClass));

  @override
  Widget build(BuildContext context) {
    final labels = [
      docenteText(context, 'docente_section_my_classes'),
      docenteText(context, 'docente_section_all_classes'),
      docenteText(context, 'docente_section_extra'),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(docenteText(context, 'docente_classes'))),
      body: RefreshIndicator(
        key: docenteClassesRefresherKey,
        onRefresh: _refresh,
        child: ListView(
          children: [
            DocenteChips(
                labels: labels,
                selected: _chip,
                onSelected: (i) => setState(() => _chip = i)),
            if (_chip == 0) _myClasses() else _directoryView(_directory(_chip)),
          ],
        ),
      ),
    );
  }

  Widget _state<T>(AsyncSnapshot<T> snapshot) => snapshot.hasError
      ? Padding(
          padding: const EdgeInsets.only(top: 64),
          child: CustomPlaceHolder(
            icon: Icons.error_outline,
            text: docenteText(context, 'docente_error'),
            showUpdate: true,
            updateMessage: AppLocalizations.of(context)!.translate('sync'),
            onTap: _refresh,
          ),
        )
      : const Padding(
          padding: EdgeInsets.only(top: 64),
          child: Center(child: CircularProgressIndicator()));

  Widget _myClasses() => FutureBuilder<List<DocenteClass>>(
        future: _mine,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return _state(snapshot);
          final classes = snapshot.data!;
          if (classes.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 64),
              child: CustomPlaceHolder(
                  icon: Icons.class_,
                  text: docenteText(context, 'docente_no_classes'),
                  showUpdate: false),
            );
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(children: [
              for (final docenteClass in classes)
                DocenteCircleCard(
                  circleText: docenteClass.name,
                  title: docenteClass.subjects.map((s) => s.name).join(' · '),
                  subtitle: docenteClass.course,
                  onTap: () => _open(docenteClass),
                ),
            ]),
          );
        },
      );

  Widget _directoryView(Future<List<DocenteDirectoryGroup>> future) =>
      FutureBuilder<List<DocenteDirectoryGroup>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return _state(snapshot);
          final groups =
              snapshot.data!.where((g) => g.entries.isNotEmpty).toList();
          if (groups.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 64),
              child: CustomPlaceHolder(
                  icon: Icons.class_,
                  text: docenteText(context, 'docente_no_classes'),
                  showUpdate: false),
            );
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final group in groups) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: HeaderText(
                        text: [group.title, group.subtitle]
                            .where((s) => s.isNotEmpty)
                            .join(' · ')),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final entry in group.entries)
                        ActionChip(
                          label: Text(entry.name),
                          tooltip:
                              entry.subtitle.isEmpty ? null : entry.subtitle,
                          onPressed: () => _open(entry.toClass()),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      );
}
