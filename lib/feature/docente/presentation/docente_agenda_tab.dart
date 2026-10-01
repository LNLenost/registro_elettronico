import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/core/presentation/widgets/cusotm_placeholder.dart';
import 'package:registro_elettronico/feature/docente/data/docente_web_api.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_navigator_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_widgets.dart';

/// Personal agenda of the teacher, laid out as the student agenda: calendar,
/// then the event cards of the selected day.
class DocenteAgendaTab extends StatefulWidget {
  const DocenteAgendaTab({Key? key}) : super(key: key);

  @override
  _DocenteAgendaTabState createState() => _DocenteAgendaTabState();
}

class _DocenteAgendaTabState extends State<DocenteAgendaTab> {
  DateTime _selectedDay = DateUtils.dateOnly(DateTime.now());
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  Future<List<DocenteAgendaEvent>>? _events;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _events ??= _fetch();
  }

  /// The visible month plus the days shown around it.
  Future<List<DocenteAgendaEvent>> _fetch() {
    final scope = DocenteScope.of(context);
    final from =
        DateTime(_month.year, _month.month).subtract(const Duration(days: 7));
    final to =
        DateTime(_month.year, _month.month + 1).add(const Duration(days: 7));
    return scope.guard(scope.api.getAgenda(from, to));
  }

  Future<void> _refresh() async {
    final future = _fetch();
    setState(() => _events = future);
    await future.catchError((_) => <DocenteAgendaEvent>[]);
  }

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(trans.translate('agenda')!),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => docenteAgendaRefresherKey.currentState?.show()),
        ],
      ),
      body: RefreshIndicator(
        key: docenteAgendaRefresherKey,
        onRefresh: _refresh,
        child: FutureBuilder<List<DocenteAgendaEvent>>(
          future: _events,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ListView(children: [
                const SizedBox(height: 120),
                CustomPlaceHolder(
                  icon: Icons.error_outline,
                  text: docenteText(context, 'docente_error'),
                  showUpdate: true,
                  onTap: _refresh,
                ),
              ]);
            }
            final events = [
              for (final e in snapshot.data ?? const <DocenteAgendaEvent>[])
                if (e.start != null) e,
            ];
            final calendarEvents = [
              for (final e in events) docenteCalendarEventOf(e)
            ];
            final dayEvents = calendarEvents
                .where((e) => DateUtils.isSameDay(e.start, _selectedDay))
                .toList()
              ..sort((a, b) => a.start.compareTo(b.start));
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: DocenteCalendar(
                    events: calendarEvents,
                    selectedDay: _selectedDay,
                    onDaySelected: (day) =>
                        setState(() => _selectedDay = DateUtils.dateOnly(day)),
                    onPageChanged: (focused) {
                      final month = DateTime(focused.year, focused.month);
                      if (month == _month) return;
                      _month = month;
                      _refresh();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                if (!snapshot.hasData)
                  const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()))
                else if (dayEvents.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 64),
                    child: Text(trans.translate('empty_events')!,
                        textAlign: TextAlign.center),
                  )
                else
                  for (final event in dayEvents)
                    docenteEventCard(context, event),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Teacher agenda event -> calendar event (title: class and subject, as the
/// web agenda; colour: the web label colour).
DocenteCalendarEvent docenteCalendarEventOf(DocenteAgendaEvent e) {
  // class_desc is "3TELB TELECOMUNICAZIONI": the class code, then the course.
  final title = [e.className.split(' ').first, e.subject]
      .where((s) => s.isNotEmpty)
      .join(' · ');
  return DocenteCalendarEvent(
    start: e.start!,
    end: e.end,
    allDay: e.allDay,
    title: title.isNotEmpty ? title : e.title,
    subtitle:
        e.note.isNotEmpty ? e.note : (title.isNotEmpty ? e.title : e.kind),
    color: docenteColor(e.color),
  );
}

Widget docenteEventCard(BuildContext context, DocenteCalendarEvent event) {
  final trans = AppLocalizations.of(context)!;
  return DocenteEventCard(
    event: event,
    hourLabel: trans.translate('hour')!,
    allDayLabel: trans.translate('all_day_card')!,
    timeText: DateFormat.Hm(trans.locale.toString()).format(event.start),
  );
}
