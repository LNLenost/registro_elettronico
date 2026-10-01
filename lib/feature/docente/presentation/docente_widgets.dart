import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:registro_elettronico/core/infrastructure/app_injection.dart';
import 'package:registro_elettronico/utils/color_utils.dart';
import 'package:registro_elettronico/utils/constants/preferences_constants.dart';
import 'package:registro_elettronico/utils/global_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

/// Widgets of the teacher area that replicate the student ones, so the two
/// areas look the same: the agenda calendar and event cards, the grade /
/// absence coloured cards, the grades chips row, the subject average card and
/// the home lesson card.

/// School year months, September to June.
List<DateTime> docenteSchoolMonths(DateTime now) {
  final startYear = now.month >= 9 ? now.year : now.year - 1;
  return [for (var i = 0; i < 10; i++) DateTime(startYear, 9 + i)];
}

/// An event shown on the calendar and in the day list.
class DocenteCalendarEvent {
  final DateTime start;
  final DateTime? end;
  final bool allDay;
  final String title;
  final String subtitle;
  final Color color;

  const DocenteCalendarEvent({
    required this.start,
    required this.end,
    required this.allDay,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

/// `#RRGGBB` (as sent by the web register) to a colour.
Color docenteColor(String? hex, {Color fallback = Colors.red}) {
  final value = int.tryParse((hex ?? '').replaceFirst('#', ''), radix: 16);
  if (value == null) return fallback;
  return Color(
      hex!.replaceFirst('#', '').length <= 6 ? 0xFF000000 | value : value);
}

/// The agenda calendar with the same configuration as the student agenda
/// (feature/agenda/presentation/loaded/agenda_loaded.dart).
class DocenteCalendar extends StatefulWidget {
  final List<DocenteCalendarEvent> events;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime>? onPageChanged;

  const DocenteCalendar({
    Key? key,
    required this.events,
    required this.selectedDay,
    required this.onDaySelected,
    this.onPageChanged,
  }) : super(key: key);

  @override
  _DocenteCalendarState createState() => _DocenteCalendarState();
}

class _DocenteCalendarState extends State<DocenteCalendar> {
  late CalendarFormat _format;
  late DateTime _focusedDay = widget.selectedDay;

  @override
  void initState() {
    super.initState();
    final stored =
        sl<SharedPreferences>().getInt(PrefsConstants.preferredCalendarFormat);
    _format =
        stored == null ? CalendarFormat.month : CalendarFormat.values[stored];
  }

  List<DocenteCalendarEvent> _eventsFor(DateTime day) =>
      widget.events.where((e) => isSameDay(e.start, day)).toList();

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    const plain = BoxDecoration(shape: BoxShape.rectangle);
    return TableCalendar<DocenteCalendarEvent>(
      calendarFormat: _format,
      startingDayOfWeek: StartingDayOfWeek.monday,
      weekendDays: const [DateTime.sunday],
      onDaySelected: (selected, focused) {
        setState(() => _focusedDay = focused);
        widget.onDaySelected(selected);
      },
      onPageChanged: (focused) {
        _focusedDay = focused;
        widget.onPageChanged?.call(focused);
      },
      eventLoader: _eventsFor,
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      calendarBuilders: CalendarBuilders(
        singleMarkerBuilder: (context, date, DocenteCalendarEvent event) =>
            Container(
          decoration: BoxDecoration(shape: BoxShape.circle, color: event.color),
          width: 7.0,
          height: 7.0,
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
        ),
      ),
      calendarStyle: CalendarStyle(
        weekendDecoration: plain,
        rangeEndDecoration: plain,
        defaultDecoration: plain,
        rowDecoration: plain,
        markerDecoration: plain,
        holidayDecoration: plain,
        outsideDecoration: plain,
        disabledDecoration: plain,
        rangeStartDecoration: plain,
        withinRangeDecoration: plain,
        selectedDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: accent.withOpacity(0.7),
          borderRadius: BorderRadius.circular(4),
        ),
        todayDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: accent.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        outsideDaysVisible: false,
        outsideTextStyle: TextStyle(color: Colors.grey[300]),
        weekendTextStyle: TextStyle(color: accent),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(weekendStyle: TextStyle(color: accent)),
      headerStyle: HeaderStyle(
        formatButtonTextStyle:
            const TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16.0),
        ),
        formatButtonVisible: true,
      ),
      onFormatChanged: (format) {
        setState(() => _format = format);
        sl<SharedPreferences>()
            .setInt(PrefsConstants.preferredCalendarFormat, format.index);
      },
    );
  }
}

/// Event card of the agenda day list (as the student EventCard): coloured
/// card, white hour column, white bold title and white notes.
class DocenteEventCard extends StatelessWidget {
  final DocenteCalendarEvent event;
  final String hourLabel;
  final String allDayLabel;
  final String timeText;

  const DocenteEventCard({
    Key? key,
    required this.event,
    required this.hourLabel,
    required this.allDayLabel,
    required this.timeText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const white = TextStyle(color: Colors.white);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 6.0),
      child: Card(
        color: event.color,
        child: ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: event.allDay
                ? [Text(allDayLabel, style: white, textAlign: TextAlign.center)]
                : [
                    Text(hourLabel.toLowerCase(), style: white),
                    Text(timeText, style: white)
                  ],
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(event.title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          subtitle: event.subtitle.isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(event.subtitle, style: white),
                ),
        ),
      ),
    );
  }
}

/// Coloured card with a white round badge, as the student grade and absence
/// cards (SRGradeCard / AbsenceCard).
class DocenteColoredCard extends StatelessWidget {
  final Color color;
  final String badge;
  final List<String> lines;
  final VoidCallback? onTap;

  const DocenteColoredCard({
    Key? key,
    required this.color,
    required this.badge,
    required this.lines,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final visible = lines.where((l) => l.trim().isNotEmpty).toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipOval(
                    child: Container(
                      color: Colors.white,
                      width: 55,
                      height: 55,
                      alignment: Alignment.center,
                      child: Text(
                        badge,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < visible.length; i++)
                          Text(
                            visible[i],
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: i == 0 ? 15 : 12),
                            maxLines: i == 0 ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The chips row at the top of the grades page.
class DocenteChips extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  const DocenteChips(
      {Key? key,
      required this.labels,
      required this.selected,
      required this.onSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
        child: SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (var i = 0; i < labels.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(labels[i]),
                    backgroundColor: i == selected
                        ? Theme.of(context).colorScheme.secondary
                        : null,
                    onPressed: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      );
}

/// Card with a round indicator on the left, as the subject card of the
/// grades period tab (PeriodGradeCard).
class DocenteCircleCard extends StatelessWidget {
  final String title;
  final String subtitle;

  /// Average shown in the indicator (null: [circleText] in a plain circle).
  final double? average;
  final String? circleText;
  final VoidCallback? onTap;
  final Widget? below;

  const DocenteCircleCard({
    Key? key,
    required this.title,
    required this.subtitle,
    this.average,
    this.circleText,
    this.onTap,
    this.below,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    // No average (e.g. no grades yet): an empty grey ring, not a coloured one.
    final Widget circle = average != null
        ? CircularPercentIndicator(
            radius: 60,
            lineWidth: 6,
            percent: (average! / 10).clamp(0.0, 1.0),
            center: Text(average!.toStringAsFixed(1)),
            progressColor: GlobalUtils.getColorFromAverage(average) ?? accent,
          )
        : CircularPercentIndicator(
            radius: 60,
            lineWidth: 6,
            percent: circleText == null || circleText == '-' ? 0 : 1,
            center: Padding(
              padding: const EdgeInsets.all(8),
              child: FittedBox(
                  child: Text(circleText ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.w600))),
            ),
            progressColor: accent,
          );
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              circle,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15)),
                    if (subtitle.isNotEmpty) const SizedBox(height: 4),
                    if (subtitle.isNotEmpty)
                      Text(subtitle, style: const TextStyle(fontSize: 12)),
                    if (below != null) below!,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal lesson card of the home page (as the student LessonCard):
/// accent card with the subject icon, a pill and white texts.
class DocenteLessonCard extends StatelessWidget {
  final int position;
  final String subject;
  final String pill;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const DocenteLessonCard({
    Key? key,
    required this.position,
    required this.subject,
    required this.pill,
    required this.title,
    required this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: position == 0 ? 16.0 : 0, right: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 220.0,
          height: 140,
          decoration: BoxDecoration(
            color: ColorUtils.getLessonCardColor(context),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipOval(
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.white,
                        child: GlobalUtils.getIconFromSubject(subject),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200]!.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Opacity(
                        opacity: 0.85,
                        child: Text(pill,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10)),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .headline5!
                            .copyWith(fontSize: 12, color: Colors.white),
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
