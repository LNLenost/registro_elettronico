import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/core/presentation/widgets/cusotm_placeholder.dart';
import 'package:registro_elettronico/feature/docente/data/docente_web_api.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_navigator_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_widgets.dart';
import 'package:registro_elettronico/feature/home/sections/events/agenda_timeline.dart';
import 'package:registro_elettronico/feature/home/sections/header/week_summary_chart.dart';
import 'package:registro_elettronico/utils/color_utils.dart';
import 'package:registro_elettronico/utils/date_utils.dart';
import 'package:registro_elettronico/utils/string_utils.dart';

/// Teacher home, laid out as the student home (feature/home/home_page.dart):
/// gradient header with greeting, date and week chart, quick actions, today's
/// lessons as horizontal cards, next events on the timeline and the notices
/// to read.
class DocenteDashboardPage extends StatefulWidget {
  const DocenteDashboardPage({Key? key}) : super(key: key);

  @override
  _DocenteDashboardPageState createState() => _DocenteDashboardPageState();
}

class _DashboardData {
  final String name;
  final List<DocenteAgendaEvent> week;
  final DocenteNotices notices;

  const _DashboardData(this.name, this.week, this.notices);
}

class _DocenteDashboardPageState extends State<DocenteDashboardPage> {
  Future<_DashboardData>? _data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data ??= _fetch();
  }

  Future<_DashboardData> _fetch() {
    final scope = DocenteScope.of(context);
    final today = DateUtils.dateOnly(DateTime.now());
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return scope.guard(Future.wait<Object>([
      scope.api.getUsername(),
      scope.api.getAgenda(monday, monday.add(const Duration(days: 14))),
      scope.api.getNotices(),
    ]).then((r) => _DashboardData(r[0] as String,
        r[1] as List<DocenteAgendaEvent>, r[2] as DocenteNotices)));
  }

  Future<void> _refresh() async {
    final future = _fetch();
    setState(() => _data = future);
    await future.catchError((_) =>
        const _DashboardData('', [], DocenteNotices(unread: [], read: [])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        key: docenteHomeRefresherKey,
        onRefresh: _refresh,
        child: FutureBuilder<_DashboardData>(
          future: _data,
          builder: (context, snapshot) {
            final data = snapshot.data;
            return ListView(
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics()),
              children: [
                _Header(name: data?.name ?? '', week: data?.week ?? const []),
                const _Actions(),
                if (snapshot.hasError)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: CustomPlaceHolder(
                      icon: Icons.error_outline,
                      text: docenteText(context, 'docente_error'),
                      showUpdate: true,
                      onTap: _refresh,
                    ),
                  )
                else if (data == null)
                  const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()))
                else ...[
                  _TodayLessons(events: data.week),
                  _NextEvents(events: data.week),
                  _NoticesToRead(notices: data.notices),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

bool _isLesson(DocenteAgendaEvent e) =>
    e.kind.toLowerCase().startsWith('lezion');

class _Header extends StatelessWidget {
  final String name;
  final List<DocenteAgendaEvent> week;

  const _Header({required this.name, required this.week});

  /// Events per day, Monday..Saturday of the current week (as the student
  /// agenda repository builds the chart spots: x = 1..6).
  List<FlSpot> _spots() {
    final today = DateUtils.dateOnly(DateTime.now());
    var first = today.subtract(Duration(days: today.weekday - 1));
    if (today.weekday == DateTime.sunday) {
      first = today.add(const Duration(days: 1));
    }
    return [
      for (var i = 1; i <= 6; i++)
        FlSpot(
            i.toDouble(),
            week
                .where((e) =>
                    e.start != null &&
                    DateUtils.isSameDay(
                        e.start, first.add(Duration(days: i - 1))))
                .length
                .toDouble()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final firstName = name.split(' ').first;
    return Stack(children: [
      Container(
        height: 220,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            stops: const [0.4, 1],
            colors: ColorUtils.getGradientForColor(
                Theme.of(context).colorScheme.secondary),
            begin: const Alignment(-1.0, -2.0),
            end: const Alignment(1.0, 2.0),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).viewPadding.top + 24),
            Text(
              '${SRDateUtils.localizedTimeMessage(context)}${firstName.isEmpty ? '' : ', ${StringUtils.titleCase(firstName)}'}.',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w400),
            ),
            Text(
              SRDateUtils.convertDateLocale(DateTime.now(),
                  AppLocalizations.of(context)!.locale.toString()),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              elevation: 2,
              child: AspectRatio(
                aspectRatio: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(1, 0, 24, 0),
                  child: WeekSummaryChart(events: _spots()),
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}

/// Quick actions row (the student home has timetable and substitutions).
class _Actions extends StatelessWidget {
  const _Actions();

  @override
  Widget build(BuildContext context) {
    final scope = DocenteScope.of(context);
    Widget action(IconData icon, String text, VoidCallback onTap) => Expanded(
          child: Card(
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                    Flexible(child: Text(text))
                  ],
                ),
              ),
            ),
          ),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(children: [
        action(Icons.class_, docenteText(context, 'docente_section_my_classes'),
            () => scope.openTab(DocenteTab.classes, classesChip: 0)),
        action(
            Icons.view_module,
            docenteText(context, 'docente_section_all_classes'),
            () => scope.openTab(DocenteTab.classes, classesChip: 1)),
      ]),
    );
  }
}

class _TodayLessons extends StatelessWidget {
  final List<DocenteAgendaEvent> events;

  const _TodayLessons({required this.events});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final lessons = events
        .where((e) =>
            _isLesson(e) &&
            e.start != null &&
            DateUtils.isSameDay(e.start, today))
        .toList()
      ..sort((a, b) => a.start!.compareTo(b.start!));
    final time = DateFormat.Hm(Localizations.localeOf(context).toString());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(docenteText(context, 'docente_lessons_today')),
        ),
        SizedBox(
          height: 140,
          child: lessons.isEmpty
              ? CustomPlaceHolder(
                  icon: Icons.subject,
                  text: docenteText(context, 'docente_no_lessons_today'),
                  showUpdate: false,
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: lessons.length,
                  itemBuilder: (context, i) {
                    final lesson = lessons[i];
                    return DocenteLessonCard(
                      position: i,
                      subject: lesson.subject,
                      pill: time.format(lesson.start!),
                      title: [lesson.className.split(' ').first, lesson.subject]
                          .where((s) => s.isNotEmpty)
                          .join(' · '),
                      subtitle:
                          lesson.note.isNotEmpty ? lesson.note : lesson.title,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _NextEvents extends StatelessWidget {
  final List<DocenteAgendaEvent> events;

  const _NextEvents({required this.events});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final next = events
        .where((e) =>
            !_isLesson(e) &&
            e.start != null &&
            !e.start!.isBefore(DateUtils.dateOnly(now)))
        .toList()
      ..sort((a, b) => a.start!.compareTo(b.start!));
    final trans = AppLocalizations.of(context)!;
    final date = DateFormat('d MMM', trans.locale.toString());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(trans.translate('next_events')!),
        ),
        if (next.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 54),
            child: CustomPlaceHolder(
                icon: Icons.event,
                text: trans.translate('no_events'),
                showUpdate: false),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AgendaTimeline(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              indicators: [
                for (final _ in next.take(3)) const Icon(Icons.calendar_today)
              ],
              children: [
                for (final event in next.take(3))
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              event.title.isNotEmpty ? event.title : event.kind,
                              style: const TextStyle(fontSize: 15)),
                          Text(
                            [event.className, date.format(event.start!)]
                                .where((s) => s.isNotEmpty)
                                .join(' - '),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (next.length > 3)
          TextButton(
            onPressed: () =>
                DocenteScope.of(context).openTab(DocenteTab.agenda),
            child: Text(trans.translate('show_others')!.toUpperCase()),
          ),
      ],
    );
  }
}

/// As the homework section of the student home: hidden when empty.
class _NoticesToRead extends StatelessWidget {
  final DocenteNotices notices;

  const _NoticesToRead({required this.notices});

  @override
  Widget build(BuildContext context) {
    if (notices.unread.isEmpty) return const SizedBox(height: 16);
    final date =
        DateFormat('d MMM', Localizations.localeOf(context).toString());
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(docenteText(context, 'docente_notices_to_read')),
          const SizedBox(height: 8),
          for (final notice in notices.unread.take(3))
            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: Text(notice.title,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text([
                  notice.category,
                  if (notice.publishedOn != null)
                    date.format(notice.publishedOn!)
                ].join(' · ')),
              ),
            ),
          TextButton(
            onPressed: () =>
                DocenteScope.of(context).openTab(DocenteTab.noticeboard),
            child: Text(AppLocalizations.of(context)!
                .translate('show_others')!
                .toUpperCase()),
          ),
        ],
      ),
    );
  }
}
