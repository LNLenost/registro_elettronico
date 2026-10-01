import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/core/presentation/widgets/cusotm_placeholder.dart';
import 'package:registro_elettronico/feature/docente/data/docente_absences_parser.dart';
import 'package:registro_elettronico/feature/docente/data/docente_classes_parser.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_register_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_widgets.dart';
import 'package:registro_elettronico/feature/settings/widgets/header_text.dart';
import 'package:registro_elettronico/utils/color_utils.dart';
import 'package:registro_elettronico/utils/constants/registro_constants.dart';

/// Absences of a class, as the student absences page: the statistics card
/// with the three indicators (absences, early exits, lates), then the
/// students; a student opens their events as coloured absence cards split in
/// not justified / justified. Months are chosen with chips.
class DocenteAbsencesPage extends StatefulWidget {
  final DocenteLink link;
  final String title;

  const DocenteAbsencesPage({Key? key, required this.link, required this.title})
      : super(key: key);

  @override
  _DocenteAbsencesPageState createState() => _DocenteAbsencesPageState();
}

class _DocenteAbsencesPageState extends State<DocenteAbsencesPage> {
  late final List<DateTime> _months = docenteSchoolMonths(DateTime.now());
  late int _monthIndex = _months.indexWhere(
      (m) => m.year == DateTime.now().year && m.month == DateTime.now().month);
  Future<List<DocenteStudentAbsences>>? _students;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_monthIndex < 0) _monthIndex = 0;
    _students ??= _fetch();
  }

  Future<List<DocenteStudentAbsences>> _fetch() {
    final scope = DocenteScope.of(context);
    final path = docentePathForDay(widget.link.path, _months[_monthIndex]);
    return scope.guard(
        scope.api.getPage(path).then(parseDocenteAbsences).then((students) {
      // Counts only (no names), to check parsing against the web page.
      debugPrint('[DocenteAbsences] students=${students.length} '
          'totals=${students.map((s) => '${s.absences}/${s.lates}/${s.exits}').toList()} '
          'events=${students.map((s) => s.events.length).toList()}');
      return students;
    }));
  }

  Future<void> _refresh() async {
    final future = _fetch();
    setState(() => _students = future);
    await future.catchError((_) => <DocenteStudentAbsences>[]);
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
            FutureBuilder<List<DocenteStudentAbsences>>(
              future: _students,
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
                final students = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StatsCard(students: students),
                      const SizedBox(height: 8),
                      for (final student in students)
                        _StudentCard(student: student),
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

Color _kindColor(DocenteAbsenceKind kind) {
  switch (kind) {
    case DocenteAbsenceKind.absence:
      return ColorUtils.getColorFromCode(RegistroConstants.ASSENZA)!;
    case DocenteAbsenceKind.late:
      return ColorUtils.getColorFromCode(RegistroConstants.RITARDO)!;
    case DocenteAbsenceKind.exit:
      return ColorUtils.getColorFromCode(RegistroConstants.USCITA)!;
  }
}

const _kindKeys = {
  DocenteAbsenceKind.absence: 'docente_absence',
  DocenteAbsenceKind.late: 'docente_late',
  DocenteAbsenceKind.exit: 'docente_exit',
};

const _kindLetters = {
  DocenteAbsenceKind.absence: 'A',
  DocenteAbsenceKind.late: 'R',
  DocenteAbsenceKind.exit: 'U',
};

/// Class totals with the three indicators of the student statistics card.
class _StatsCard extends StatelessWidget {
  final List<DocenteStudentAbsences> students;

  const _StatsCard({required this.students});

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    final counts = {
      for (final kind in DocenteAbsenceKind.values)
        kind: students.fold<int>(
            0, (n, s) => n + s.events.where((e) => e.kind == kind).length),
    };
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    Widget indicator(DocenteAbsenceKind kind, String label) =>
        Column(children: [
          CircularPercentIndicator(
            radius: 65,
            lineWidth: 6,
            percent: total == 0 ? 0 : counts[kind]! / total,
            center:
                Text('${counts[kind]}', style: const TextStyle(fontSize: 18)),
            progressColor: _kindColor(kind),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ]);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            indicator(DocenteAbsenceKind.absence, trans.translate('absences')!),
            indicator(DocenteAbsenceKind.exit, trans.translate('early_exits')!),
            indicator(DocenteAbsenceKind.late, trans.translate('delay')!),
          ],
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final DocenteStudentAbsences student;

  const _StudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final summary = docenteText(context, 'docente_absences_summary')
            .replaceAll('{absences}', '${student.absences}')
            .replaceAll('{lates}', '${student.lates}')
            .replaceAll('{exits}', '${student.exits}') +
        (student.absencePercent.isEmpty ? '' : ' (${student.absencePercent})');
    final unjustified = student.unjustified;
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        title: Text(student.name),
        subtitle: Text(summary),
        trailing:
            unjustified == 0 ? null : DocenteBadge('$unjustified', Colors.red),
        onTap: student.events.isEmpty
            ? null
            : () => DocenteScope.push(
                context, _StudentAbsencesPage(student: student)),
      ),
    );
  }
}

/// Events of one student, as the student absences list: not justified, then
/// justified, as coloured absence cards.
class _StudentAbsencesPage extends StatelessWidget {
  final DocenteStudentAbsences student;

  const _StudentAbsencesPage({required this.student});

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    Widget card(DocenteAbsenceEvent e) => DocenteColoredCard(
          color: _kindColor(e.kind),
          badge: _kindLetters[e.kind]!,
          lines: [e.date, docenteText(context, _kindKeys[e.kind]!)],
        );
    final notJustified = student.events.where((e) => !e.justified).toList();
    final justified = student.events.where((e) => e.justified).toList();
    return Scaffold(
      appBar: AppBar(title: Text(student.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          HeaderText(text: trans.translate('not_justified')),
          const SizedBox(height: 8),
          ...notJustified.map(card),
          const SizedBox(height: 8),
          HeaderText(text: trans.translate('justified')),
          const SizedBox(height: 8),
          if (justified.isEmpty)
            CustomPlaceHolder(
                icon: Icons.assessment,
                text: trans.translate('no_absences'),
                showUpdate: false)
          else
            ...justified.map(card),
        ],
      ),
    );
  }
}
