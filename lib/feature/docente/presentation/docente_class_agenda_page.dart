import 'package:flutter/material.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/core/presentation/widgets/cusotm_placeholder.dart';
import 'package:registro_elettronico/feature/docente/data/docente_class_agenda.dart';
import 'package:registro_elettronico/feature/docente/data/docente_classes_parser.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_agenda_tab.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_widgets.dart';

/// Class agenda (homework, tests, notes for students), as the student agenda:
/// calendar and the coloured event cards of the selected day.
class DocenteClassAgendaPage extends StatefulWidget {
  final DocenteLink link;
  final String title;

  const DocenteClassAgendaPage(
      {Key? key, required this.link, required this.title})
      : super(key: key);

  @override
  _DocenteClassAgendaPageState createState() => _DocenteClassAgendaPageState();
}

/// Colours of the student agenda "new event" menu: homework blue, tests deep
/// orange; notes for a student orange, anything else the accent colour.
Color _kindColor(BuildContext context, DocenteClassEvent e) {
  final kind = e.kind.toLowerCase();
  if (kind.contains('compit')) return Colors.blue[700]!;
  if (kind.contains('verific') || kind.contains('test')) {
    return Colors.deepOrange;
  }
  if (e.student.isNotEmpty || kind.contains('nota')) return Colors.orange;
  return Theme.of(context).colorScheme.secondary;
}

class _DocenteClassAgendaPageState extends State<DocenteClassAgendaPage> {
  DateTime _selectedDay = DateUtils.dateOnly(DateTime.now());
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  Future<List<DocenteClassEvent>>? _events;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _events ??= _fetch();
  }

  Future<List<DocenteClassEvent>> _fetch() {
    final scope = DocenteScope.of(context);
    final from =
        DateTime(_month.year, _month.month).subtract(const Duration(days: 7));
    final to =
        DateTime(_month.year, _month.month + 1).add(const Duration(days: 7));
    return scope
        .guard(scope.api.getClassAgenda(widget.link, from, to).then((events) {
      debugPrint(
          '[DocenteClassAgenda] events=${events.length} kinds=${events.map((e) => e.kind).toSet()}');
      return events;
    }));
  }

  Future<void> _refresh() async {
    final future = _fetch();
    setState(() => _events = future);
    await future.catchError((_) => <DocenteClassEvent>[]);
  }

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<DocenteClassEvent>>(
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
              for (final e in snapshot.data ?? const <DocenteClassEvent>[])
                if (e.start != null)
                  DocenteCalendarEvent(
                    start: e.start!,
                    end: e.end,
                    allDay: e.allDay,
                    title: e.student.isNotEmpty
                        ? '${e.author} · ${e.student}'
                        : e.author,
                    subtitle: [
                      e.title,
                      if (e.note != e.title) e.note,
                      e.subject
                    ].where((s) => s.isNotEmpty).join('\n'),
                    color: _kindColor(context, e),
                  ),
            ];
            final day = events
                .where((e) => DateUtils.isSameDay(e.start, _selectedDay))
                .toList();
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: DocenteCalendar(
                    events: events,
                    selectedDay: _selectedDay,
                    onDaySelected: (d) =>
                        setState(() => _selectedDay = DateUtils.dateOnly(d)),
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
                else if (day.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 64),
                    child: Text(trans.translate('empty_events')!,
                        textAlign: TextAlign.center),
                  )
                else
                  for (final event in day) docenteEventCard(context, event),
              ],
            );
          },
        ),
      ),
    );
  }
}
