import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_elettronico/core/presentation/widgets/cusotm_placeholder.dart';
import 'package:registro_elettronico/feature/docente/data/docente_classes_parser.dart';
import 'package:registro_elettronico/feature/docente/data/docente_register_parser.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_widgets.dart';
import 'package:registro_elettronico/feature/settings/widgets/header_text.dart';

/// Class register of a day: the agenda calendar to pick the day, the signed
/// lessons as the student lesson cards, then the roll call.
class DocenteRegisterPage extends StatefulWidget {
  final DocenteLink link;
  final String title;

  const DocenteRegisterPage({Key? key, required this.link, required this.title})
      : super(key: key);

  @override
  _DocenteRegisterPageState createState() => _DocenteRegisterPageState();
}

class _DocenteRegisterPageState extends State<DocenteRegisterPage> {
  DateTime _day = DateUtils.dateOnly(DateTime.now());
  Future<DocenteRegisterDay>? _register;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _register ??= _fetch();
  }

  Future<DocenteRegisterDay> _fetch() {
    final scope = DocenteScope.of(context);
    return scope.guard(scope.api
        .getPage(docentePathForDay(widget.link.path, _day))
        .then(parseDocenteRegister));
  }

  Future<void> _refresh() async {
    final future = _fetch();
    setState(() => _register = future);
    await future
        .catchError((_) => const DocenteRegisterDay(lessons: [], students: []));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: DocenteCalendar(
                events: const [],
                selectedDay: _day,
                onDaySelected: (day) {
                  _day = DateUtils.dateOnly(day);
                  _refresh();
                },
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<DocenteRegisterDay>(
              future: _register,
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
                final day = snapshot.data!;
                if (day.lessons.isEmpty && day.students.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: CustomPlaceHolder(
                      icon: Icons.library_books,
                      text: docenteText(context, 'docente_register_empty'),
                      showUpdate: false,
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Header(docenteText(context, 'docente_signed_lessons')
                          .replaceAll('{count}', '${day.lessons.length}')),
                      for (final lesson in day.lessons)
                        _LessonCard(lesson: lesson),
                      _Header(docenteText(context, 'docente_roll_call')
                          .replaceAll('{present}',
                              '${day.students.where((s) => s.present).length}')
                          .replaceAll('{total}', '${day.students.length}')),
                      for (final student in day.students)
                        _StudentTile(student: student),
                      const SizedBox(height: 16),
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

class _Header extends StatelessWidget {
  final String text;

  const _Header(this.text);

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: HeaderText(text: text));
}

/// As the student lesson card (lessons_page.dart): topic, then details.
class _LessonCard extends StatelessWidget {
  final DocenteSignedLesson lesson;

  const _LessonCard({required this.lesson});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 6),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lesson.topic.isNotEmpty ? lesson.topic : lesson.subject,
                  style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 8),
              Text(
                [lesson.teacher, lesson.subject, lesson.hour]
                    .where((s) => s.isNotEmpty)
                    .join(' - '),
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      );
}

class _StudentTile extends StatelessWidget {
  final DocenteStudentDay student;

  const _StudentTile({required this.student});

  @override
  Widget build(BuildContext context) {
    final absentHours = student.hours.where((h) => !h.present).length;
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        title: Text(student.name),
        subtitle: Text([
          if (student.statusDescription.isNotEmpty) student.statusDescription,
          if (student.present && absentHours > 0)
            docenteText(context, 'docente_absent_hours')
                .replaceAll('{count}', '$absentHours'),
        ].join(' · ')),
        trailing: DocenteBadge(
          student.status.isEmpty
              ? (student.present ? 'P' : 'A')
              : student.status,
          student.present ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}

/// Adds or replaces `data_start=YYYY-MM-DD`, the day parameter of the
/// register pages.
String docentePathForDay(String path, DateTime day) {
  final uri = Uri.parse(path);
  final query = Map<String, String>.from(uri.queryParameters)
    ..['data_start'] = DateFormat('yyyy-MM-dd').format(day);
  return uri.replace(queryParameters: query).toString();
}
