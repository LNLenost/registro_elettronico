import 'package:flutter/material.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/feature/docente/data/docente_classes_parser.dart';
import 'package:registro_elettronico/feature/docente/data/docente_grades_parser.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_widgets.dart';
import 'package:registro_elettronico/utils/global_utils.dart';

/// Grades of a class for one subject, as the student grades period tab:
/// the class average card, then one card per student with the average
/// indicator; a student opens their grades as coloured grade cards.
class DocenteGradesPage extends StatefulWidget {
  final DocenteLink link;
  final String title;

  const DocenteGradesPage({Key? key, required this.link, required this.title})
      : super(key: key);

  @override
  _DocenteGradesPageState createState() => _DocenteGradesPageState();
}

class _DocenteGradesPageState extends State<DocenteGradesPage> {
  Future<List<DocenteStudentGrades>>? _students;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _students ??= _fetch();
  }

  Future<List<DocenteStudentGrades>> _fetch() {
    final scope = DocenteScope.of(context);
    return scope
        .guard(scope.api.getPage(widget.link.path).then(parseDocenteGrades));
  }

  Future<void> _refresh() async {
    final future = _fetch();
    setState(() => _students = future);
    await future.catchError((_) => <DocenteStudentGrades>[]);
  }

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: DocenteAsyncView<List<DocenteStudentGrades>>(
        future: _students,
        onRefresh: _refresh,
        isEmpty: (students) => students.isEmpty,
        emptyText: docenteText(context, 'docente_no_students'),
        emptyIcon: Icons.timeline,
        builder: (students) {
          final averages =
              students.map((s) => s.average).whereType<double>().toList();
          final classAverage = averages.isEmpty
              ? null
              : averages.reduce((a, b) => a + b) / averages.length;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DocenteCircleCard(
                average: classAverage,
                circleText: '-',
                title: docenteText(context, 'docente_class_average'),
                subtitle: docenteText(context, 'docente_students_with_grades')
                    .replaceAll('{graded}',
                        '${students.where((s) => s.grades.isNotEmpty).length}')
                    .replaceAll('{total}', '${students.length}'),
              ),
              const SizedBox(height: 8),
              for (final student in students)
                DocenteCircleCard(
                  average: student.average,
                  circleText: '-',
                  title: student.name,
                  subtitle: student.grades.isEmpty
                      ? trans.translate('no_grades')!
                      : docenteText(context, 'docente_grades_count')
                          .replaceAll('{count}', '${student.grades.length}'),
                  onTap: student.grades.isEmpty
                      ? null
                      : () => DocenteScope.push(
                          context,
                          _StudentGradesPage(
                              student: student, subject: widget.title)),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Grades of one student, as the student grades tab: coloured grade cards.
class _StudentGradesPage extends StatelessWidget {
  final DocenteStudentGrades student;
  final String subject;

  const _StudentGradesPage({required this.student, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(student.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          for (final grade in student.grades)
            DocenteColoredCard(
              color:
                  GlobalUtils.getColorFromAverage(grade.numeric) ?? Colors.blue,
              badge: grade.value,
              lines: ['$subject - ${grade.component}', grade.note, grade.date],
            ),
        ],
      ),
    );
  }
}
