import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:registro_elettronico/core/data/local/moor_database.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/core/presentation/custom/states/sr_alternative_loading_view.dart';
import 'package:registro_elettronico/core/presentation/widgets/cusotm_placeholder.dart';
import 'package:registro_elettronico/core/presentation/widgets/custom_refresher.dart';
import 'package:registro_elettronico/feature/absences/presentation/bloc/absences_bloc.dart';
import 'package:registro_elettronico/feature/absences/presentation/widgets/absences_chart_lines.dart';
import 'package:registro_elettronico/utils/constants/registro_constants.dart';

import 'widgets/absence_card.dart';

List<Absence> filterAbsencesByDateRange(
    List<Absence> absences, DateTimeRange? range) {
  if (range == null) return absences;

  final start = DateTime(range.start.year, range.start.month, range.start.day);
  final end = DateTime(range.end.year, range.end.month, range.end.day);

  return absences.where((absence) {
    final date = absence.evtDate;
    if (date == null) return false;
    final day = DateTime(date.year, date.month, date.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }).toList();
}

class AbsencesList extends StatefulWidget {
  const AbsencesList({
    Key? key,
  }) : super(key: key);

  @override
  _AbsencesListState createState() => _AbsencesListState();
}

class _AbsencesListState extends State<AbsencesList> {
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AbsencesBloc, AbsencesState>(
      builder: (context, state) {
        if (state is AbsencesLoading) {
          return SRAlternativeLoadingView();
        }

        if (state is AbsencesLoaded) {
          final List<Absence> absences =
              filterAbsencesByDateRange(state.absences, _dateRange);
          final sortedAbsences = List<Absence>.of(absences)
            ..sort((b, a) => a.evtDate!.compareTo(b.evtDate!));
          final map = getAbsencesMap(sortedAbsences);

          return CustomRefresher(
            onRefresh: () => _updateAbsences(context),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    _buildDateRangeFilter(context),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildOverallStats(absences, context),
                    ),
                    _buildNotJustifiedAbsences(map, context),
                    _buildJustifiedAbsences(map, context),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is AbsencesError) {
          return CustomPlaceHolder(
            text: AppLocalizations.of(context)!
                .translate('unexcepted_error_single'),
            icon: Icons.error,
            onTap: () {
              _updateAbsences(context);
              // BlocProvider.of<AbsencesBloc>(context).add(GetAbsences());
            },
            showUpdate: true,
          );
        }

        return SRAlternativeLoadingView();
      },
    );
  }

  Widget _buildDateRangeFilter(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    final label = _dateRange == null
        ? trans.translate('filter_by_date_range')!
        : '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}';

    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          OutlinedButton.icon(
            icon: const Icon(Icons.date_range),
            label: Text(label),
            onPressed: () async {
              final selected = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDateRange: _dateRange,
              );
              if (mounted && selected != null) {
                setState(() => _dateRange = selected);
              }
            },
          ),
          if (_dateRange != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: trans.translate('clear_date_filter'),
              onPressed: () => setState(() => _dateRange = null),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  /// Overall stat that contains all the [circles] and the [graph]
  Widget _buildOverallStats(List<Absence> absences, BuildContext context) {
    final Map<int?, List<Absence>> absencesMonthMap = Map.fromIterable(absences,
        key: (e) => e.evtDate.month,
        value: (e) => absences
            .where((event) => e.evtDate.month == event.evtDate!.month)
            .toList());

    int numberOfAbsences = 0;
    int numberOfUscite = 0;
    int numberOfRitardi = 0;

    absences.forEach((absence) {
      if (absence.evtCode == RegistroConstants.ASSENZA) numberOfAbsences++;
      if (absence.evtCode == RegistroConstants.RITARDO ||
          absence.evtCode == RegistroConstants.RITARDO_BREVE) numberOfRitardi++;
      if (absence.evtCode == RegistroConstants.USCITA) numberOfUscite++;
    });

    final trans = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildStatsCircle(
                    trans.translate('absences')!,
                    numberOfAbsences,
                    Colors.red,
                    true,
                    numberOfAbsences / 50,
                  ),
                  _buildStatsCircle(trans.translate('early_exits')!,
                      numberOfUscite, Colors.yellow[700], false, 1.0),
                  _buildStatsCircle(trans.translate('delay')!, numberOfRitardi,
                      Colors.blue, false, 1.0)
                ],
              ),
            ),
          ),
          AbsencesChartLines(
            absences: absencesMonthMap,
          )
        ],
      ),
    );
  }

  Widget _buildStatsCircle(String typeOfEvent, int numberOfEvent, Color? color,
      bool withAnimation, double percent) {
    return Column(
      children: <Widget>[
        CircularPercentIndicator(
          radius: 65.0,
          lineWidth: 6.0,
          percent: percent,
          animation: withAnimation,
          animationDuration: 300,
          center: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              numberOfEvent.toString(),
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          progressColor: color,
        ),
        const SizedBox(
          height: 4,
        ),
        Text(typeOfEvent)
      ],
    );
  }

  /// The list of absences that are not justified
  Widget _buildNotJustifiedAbsences(
      Map<Absence, int> absences, BuildContext context) {
    final Map<Absence?, int?> notJustifiedAbsences = Map.fromIterable(
        absences.keys.where((absence) => absence.isJustified == false),
        key: (k) => k,
        value: (k) => absences[k]);
    if (notJustifiedAbsences.values.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child:
                Text(AppLocalizations.of(context)!.translate('not_justified')!),
          ),
          Column(
            children: List.generate(
              notJustifiedAbsences.keys.length,
              (index) {
                final absence = notJustifiedAbsences.keys.elementAt(index);
                final days = notJustifiedAbsences[absence];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: AbsenceCard(
                    absence: absence,
                    days: days,
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
    return Container();
  }

  Widget _buildJustifiedAbsences(
      Map<Absence, int> absences, BuildContext context) {
    final Map<Absence?, int?> justifiedAbsences = Map.fromIterable(
        absences.keys.where((absence) => absence.isJustified == true),
        key: (k) => k,
        value: (k) => absences[k]);

    if (justifiedAbsences.values.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              AppLocalizations.of(context)!.translate('justified')!,
            ),
          ),
          Column(
            children: List.generate(
              justifiedAbsences.keys.length,
              (index) {
                final absence = justifiedAbsences.keys.elementAt(index);
                final days = justifiedAbsences[absence];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: AbsenceCard(
                    absence: absence,
                    days: days,
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            height: 8,
          )
        ],
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: CustomPlaceHolder(
          text: AppLocalizations.of(context)!.translate('no_absences'),
          icon: Icons.assessment,
          onTap: () {
            BlocProvider.of<AbsencesBloc>(context).add(FetchAbsences());
            BlocProvider.of<AbsencesBloc>(context).add(GetAbsences());
          },
          showUpdate: true,
        ),
      ),
    );
  }

  Map<Absence, int> getAbsencesMap(List<Absence> absences) {
    Map<Absence, int> map = Map();
    Absence? start;
    int days = 1;
    if (absences.length == 1) {
      map[absences[0]] = 1;
      return map;
    }

    DateTime? current = DateTime.now();
    DateTime? next = DateTime.now();

    for (int i = 0; i < absences.length; i++) {
      if (absences[i].evtDate == DateTime.fromMillisecondsSinceEpoch(0)) {
        continue;
      }

      if (start == null) {
        start = absences[i];
        days = 1;
      }

      double delta = 0;

      if (absences.length > i + 1) {
        if (absences[i].evtCode == RegistroConstants.ASSENZA &&
            absences[i + 1].evtCode == RegistroConstants.ASSENZA) {
          current = absences[i].evtDate;
          next = absences[i + 1].evtDate;
        }

        delta =
            (next!.millisecondsSinceEpoch - current!.millisecondsSinceEpoch) /
                3600000;
      }

      if (absences[i].evtCode != RegistroConstants.ASSENZA) {
        map[start] = days;
        start = null;
      } else if (delta == -72) {
        if (current!.weekday == DateTime.monday &&
            next!.weekday == DateTime.friday) {
          days++;
        } else {
          map[start] = days;
          start = null;
        }
      } else if (delta == -48) {
        if (current!.weekday == DateTime.monday &&
            next!.weekday == DateTime.saturday) {
          days++;
        } else {
          map[start] = days;
          start = null;
        }
      } else if (delta == -24) {
        days++;
      } else {
        map[start] = days;
        start = null;
      }
    }

    return map;
  }

  Future _updateAbsences(BuildContext context) async {
    BlocProvider.of<AbsencesBloc>(context).add(FetchAbsences());
    BlocProvider.of<AbsencesBloc>(context).add(GetAbsences());
  }
}
