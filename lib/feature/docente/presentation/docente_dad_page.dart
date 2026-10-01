import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/core/presentation/widgets/cusotm_placeholder.dart';
import 'package:registro_elettronico/feature/docente/data/docente_classes_parser.dart';
import 'package:registro_elettronico/feature/docente/data/docente_dad_parser.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_classes_tab.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_experimental.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_register_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_widgets.dart';

/// "DAD" from the More page: the web menu asks for a class first, so this
/// lists the teacher's classes as the more page tiles.
class DocenteDadClassesPage extends StatefulWidget {
  final String title;

  const DocenteDadClassesPage({Key? key, required this.title})
      : super(key: key);

  @override
  _DocenteDadClassesPageState createState() => _DocenteDadClassesPageState();
}

class _DocenteDadClassesPageState extends State<DocenteDadClassesPage> {
  Future<List<DocenteClass>>? _classes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _classes ??= _fetch();
  }

  Future<List<DocenteClass>> _fetch() {
    final scope = DocenteScope.of(context);
    return scope.guard(
        scope.api.getPage(docenteMyClassesPath).then(parseDocenteClasses));
  }

  Future<void> _refresh() async {
    final future = _fetch();
    setState(() => _classes = future);
    await future.catchError((_) => <DocenteClass>[]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: DocenteAsyncView<List<DocenteClass>>(
        future: _classes,
        isEmpty: (classes) => classes.isEmpty,
        emptyText: docenteText(context, 'docente_classes_empty'),
        onRefresh: _refresh,
        builder: (classes) => ListView(
          children: [
            for (final docenteClass in classes)
              if (docenteClass.linkTo('didattica_distanza.php') != null)
                ListTile(
                  leading: const Icon(Icons.laptop),
                  title: Text(docenteClass.name),
                  subtitle: Text(docenteClass.course),
                  onTap: () => DocenteScope.push(
                    context,
                    DocenteDadPage(
                      link: docenteClass.linkTo('didattica_distanza.php')!,
                      title: '${widget.title} · ${docenteClass.name}',
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// Distance learning of a class, laid out as the absences page: months as
/// chips, a summary card, then one card per student with their distance
/// days. Read only: marking days stays on the web register.
class DocenteDadPage extends StatefulWidget {
  final DocenteLink link;
  final String title;

  const DocenteDadPage({Key? key, required this.link, required this.title})
      : super(key: key);

  @override
  _DocenteDadPageState createState() => _DocenteDadPageState();
}

class _DocenteDadPageState extends State<DocenteDadPage> {
  late final List<DateTime> _months = docenteSchoolMonths(DateTime.now());
  late int _monthIndex = _months.indexWhere(
      (m) => m.year == DateTime.now().year && m.month == DateTime.now().month);
  Future<DocenteDadMonth>? _data;

  String get _path => docentePathForDay(widget.link.path, _months[_monthIndex]);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_monthIndex < 0) _monthIndex = 0;
    _data ??= _fetch();
  }

  Future<DocenteDadMonth> _fetch() {
    final scope = DocenteScope.of(context);
    return scope.guard(scope.api.getPage(_path).then(parseDocenteDad).then((m) {
      debugPrint('[DocenteDad] students=${m.students.length} '
          'schoolDays=${m.schoolDays.length} '
          'distance=${m.students.map((s) => s.distanceDays.length).toList()}');
      return m;
    }));
  }

  Future<void> _refresh() async {
    final future = _fetch();
    setState(() => _data = future);
    await future
        .catchError((_) => const DocenteDadMonth(schoolDays: [], students: []));
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!.locale.toString();
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: [
            DocenteExperimentalBanner(title: widget.title, path: _path),
            DocenteChips(
              labels: [
                for (final m in _months) DateFormat.MMMM(locale).format(m)
              ],
              selected: _monthIndex,
              onSelected: (i) {
                _monthIndex = i;
                _refresh();
              },
            ),
            FutureBuilder<DocenteDadMonth>(
              future: _data,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return CustomPlaceHolder(
                    icon: Icons.error_outline,
                    text: docenteText(context, 'docente_error'),
                    showUpdate: true,
                    onTap: _refresh,
                  );
                }
                if (!snapshot.hasData) {
                  return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()));
                }
                final month = snapshot.data!;
                final total = month.students
                    .fold<int>(0, (n, s) => n + s.distanceDays.length);
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DocenteCard(
                        leading: const Icon(Icons.laptop),
                        title: docenteText(context, 'docente_dad_summary')
                            .replaceAll('{days}', '$total'),
                        details: [
                          docenteText(context, 'docente_dad_school_days')
                              .replaceAll(
                                  '{days}', '${month.schoolDays.length}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      for (final student in month.students)
                        DocenteCard(
                          title: student.name,
                          details: [
                            if (student.distanceDays.isEmpty)
                              docenteText(context, 'docente_dad_in_presence')
                            else
                              student.distanceDays
                                  .map((d) => DateFormat.MMMd(locale).format(d))
                                  .join(', '),
                          ],
                          trailing: DocenteBadge(
                            '${student.distanceDays.length}',
                            student.distanceDays.isEmpty
                                ? Colors.grey
                                : Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
