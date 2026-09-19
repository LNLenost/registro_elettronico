import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:registro_elettronico/core/infrastructure/app_injection.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/core/presentation/custom/states/sr_failure_view.dart';
import 'package:registro_elettronico/core/presentation/custom/states/sr_loading_view.dart';
import 'package:registro_elettronico/feature/timetable/domain/model/timetable_entry_domain_model.dart';
import 'package:registro_elettronico/feature/timetable/domain/repository/timetable_repository.dart';
import 'package:registro_elettronico/feature/timetable/presentation/watcher/timetable_watcher_bloc.dart';

const _weekdays = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab'];
const _subjectColors = [
  Color(0xffddc87c),
  Color(0xffcfa287),
  Color(0xffebd8c4),
  Color(0xff96b4c0),
  Color(0xffd8e6ef),
  Color(0xffc6dee9),
  Color(0xffd88579),
  Color(0xfff3f0e4),
  Color(0xffc5bfa2),
];

Color timetableColorForSubject(String? subjectName) {
  final subject = subjectName?.trim().toLowerCase() ?? '';
  return _subjectColors[subject.hashCode.abs() % _subjectColors.length];
}

class TimetablePage extends StatefulWidget {
  const TimetablePage({Key? key}) : super(key: key);

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<TimetableWatcherBloc>(context)
        .add(TimetableStartWatcherIfNeeded());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('timetable')!),
      ),
      body: BlocBuilder<TimetableWatcherBloc, TimetableWatcherState>(
        builder: (context, state) {
          if (state is TimetableWatcherLoadSuccess) {
            return _WeeklyTimetable(
              className: state.timetableData.className,
              entries: state.timetableData.entries,
            );
          }
          if (state is TimetableWatcherFailure) {
            return SRFailureView(
              failure: state.failure,
              refresh: () async => BlocProvider.of<TimetableWatcherBloc>(context)
                  .add(TimetableStartWatcherIfNeeded()),
            );
          }
          return SRLoadingView();
        },
      ),
    );
  }
}

class _WeeklyTimetable extends StatelessWidget {
  final String? className;
  final List<TimetableEntryDomainModel> entries;

  const _WeeklyTimetable({required this.className, required this.entries});

  @override
  Widget build(BuildContext context) {
    final validEntries = entries.where((entry) => entry.hasValidTimeRange).toList();
    final firstHour = validEntries.isEmpty
        ? 8
        : validEntries.map((entry) => entry.startHour).reduce(min);
    final lastHour = validEntries.isEmpty
        ? 13
        : max(firstHour + 5, validEntries.map((entry) => entry.endHour).reduce(max));
    final rowCount = lastHour - firstHour;

    return LayoutBuilder(
      builder: (context, constraints) {
        final dayWidth = ((constraints.maxWidth - 34) / 2)
            .clamp(128.0, 180.0)
            .toDouble();
        const rowHeight = 86.0;
        final gridHeight = rowCount * rowHeight;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
          child: Column(
            children: [
              Text(
                (className?.isNotEmpty == true ? className : 'CLASSE')!
                    .toUpperCase(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    _WeekHeader(dayWidth: dayWidth),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PeriodGutter(
                          firstHour: firstHour,
                          rowCount: rowCount,
                          rowHeight: rowHeight,
                        ),
                        _ScheduleGrid(
                          dayWidth: dayWidth,
                          firstHour: firstHour,
                          rowCount: rowCount,
                          rowHeight: rowHeight,
                          gridHeight: gridHeight,
                          entries: validEntries,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WeekHeader extends StatelessWidget {
  final double dayWidth;

  const _WeekHeader({required this.dayWidth});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 34),
        for (final day in _weekdays)
          Container(
            width: dayWidth,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black, width: 0.8),
                right: BorderSide(color: Colors.black, width: 0.8),
                bottom: BorderSide(color: Colors.black, width: 0.8),
              ),
            ),
            child: Text(day, style: const TextStyle(fontSize: 11)),
          ),
      ],
    );
  }
}

class _PeriodGutter extends StatelessWidget {
  final int firstHour;
  final int rowCount;
  final double rowHeight;

  const _PeriodGutter({
    required this.firstHour,
    required this.rowCount,
    required this.rowHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        rowCount,
        (index) => Container(
          width: 34,
          height: rowHeight,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black, width: 0.8)),
          ),
          child: Text(
            '${index + 1}\n${_formatHour(firstHour + index)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, height: 1.25),
          ),
        ),
      ),
    );
  }
}

class _ScheduleGrid extends StatelessWidget {
  final double dayWidth;
  final int firstHour;
  final int rowCount;
  final double rowHeight;
  final double gridHeight;
  final List<TimetableEntryDomainModel> entries;

  const _ScheduleGrid({
    required this.dayWidth,
    required this.firstHour,
    required this.rowCount,
    required this.rowHeight,
    required this.gridHeight,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: dayWidth * _weekdays.length,
      height: gridHeight,
      child: Stack(
        children: [
          Row(
            children: List.generate(
              _weekdays.length,
              (day) => Column(
                children: List.generate(
                  rowCount,
                  (row) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _editEntry(
                      context,
                      day: day,
                      startHour: firstHour + row,
                    ),
                    child: Container(
                      width: dayWidth,
                      height: rowHeight,
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.black, width: 0.8),
                          bottom: BorderSide(color: Colors.black, width: 0.8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          for (final entry in entries)
            Positioned(
              left: entry.dayOfWeek! * dayWidth,
              top: (entry.startHour - firstHour) * rowHeight,
              width: dayWidth,
              height: (entry.endHour - entry.startHour) * rowHeight,
              child: _LessonBlock(entry: entry),
            ),
        ],
      ),
    );
  }
}

class _LessonBlock extends StatelessWidget {
  final TimetableEntryDomainModel entry;

  const _LessonBlock({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: timetableColorForSubject(entry.subjectName),
      child: InkWell(
        onTap: () => _editEntry(context, entry: entry),
        child: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.black, width: 0.8),
              bottom: BorderSide(color: Colors.black, width: 0.8),
              left: BorderSide(color: Colors.black, width: 0.8),
              top: BorderSide(color: Colors.black, width: 0.8),
            ),
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.subjectName ?? 'Materia',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 3),
              Text(
                '${_formatHour(entry.startHour)} – ${_formatHour(entry.endHour)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _editEntry(
  BuildContext context, {
  int? day,
  int? startHour,
  TimetableEntryDomainModel? entry,
}) async {
  final mutation = await showDialog<_EntryMutation>(
    context: context,
    builder: (_) => _EntryEditorDialog(
      entry: entry,
      initialDay: day,
      initialStartHour: startHour,
    ),
  );
  if (mutation == null) return;

  final TimetableRepository repository = sl();
  final result = mutation.delete
      ? await repository.deleteTimetableEntry(id: entry!.id!)
      : entry == null
          ? await repository.insertTimetableEntry(entry: mutation.entry!)
          : await repository.updateTimetableEntry(entry: mutation.entry!);

  result.fold(
    (_) => ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Impossibile salvare l’orario')),
    ),
    (_) {},
  );
}

class _EntryEditorDialog extends StatefulWidget {
  final TimetableEntryDomainModel? entry;
  final int? initialDay;
  final int? initialStartHour;

  const _EntryEditorDialog({
    this.entry,
    this.initialDay,
    this.initialStartHour,
  });

  @override
  State<_EntryEditorDialog> createState() => _EntryEditorDialogState();
}

class _EntryEditorDialogState extends State<_EntryEditorDialog> {
  late final TextEditingController _subjectController;
  late int _day;
  late int _startHour;
  late int _endHour;
  String? _error;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _subjectController = TextEditingController(text: entry?.subjectName ?? '');
    _day = entry?.dayOfWeek ?? widget.initialDay ?? 0;
    _startHour = entry?.startHour ?? widget.initialStartHour ?? 8;
    _endHour = entry?.endHour ?? _startHour + 1;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.entry != null;
    return AlertDialog(
      title: Text(editing ? 'Modifica lezione' : 'Aggiungi lezione'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _subjectController,
              autofocus: !editing,
              decoration: const InputDecoration(labelText: 'Materia'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _day,
              decoration: const InputDecoration(labelText: 'Giorno'),
              items: List.generate(
                _weekdays.length,
                (index) => DropdownMenuItem(value: index, child: Text(_weekdays[index])),
              ),
              onChanged: (value) => setState(() => _day = value!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _startHour,
              decoration: const InputDecoration(labelText: 'Dalle'),
              items: List.generate(
                24,
                (hour) => DropdownMenuItem(
                  value: hour,
                  child: Text(_formatHour(hour)),
                ),
              ),
              onChanged: (value) => setState(() => _startHour = value!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _endHour,
              decoration: const InputDecoration(labelText: 'Alle'),
              items: List.generate(
                24,
                (index) {
                  final hour = index + 1;
                  return DropdownMenuItem(
                    value: hour,
                    child: Text(_formatHour(hour)),
                  );
                },
              ),
              onChanged: (value) => setState(() => _endHour = value!),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        if (editing)
          TextButton(
            onPressed: () => Navigator.pop(context, _EntryMutation.delete()),
            child: const Text('Elimina'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Salva')),
      ],
    );
  }

  void _save() {
    final subject = _subjectController.text.trim();
    if (subject.isEmpty || _endHour <= _startHour) {
      setState(() => _error = 'Inserisci una materia e un intervallo valido.');
      return;
    }
    Navigator.pop(
      context,
      _EntryMutation.save(
        TimetableEntryDomainModel.manual(
          id: widget.entry?.id,
          dayOfWeek: _day,
          subjectName: subject,
          startHour: _startHour,
          endHour: _endHour,
        ),
      ),
    );
  }
}

class _EntryMutation {
  final TimetableEntryDomainModel? entry;
  final bool delete;

  const _EntryMutation._({this.entry, required this.delete});

  factory _EntryMutation.save(TimetableEntryDomainModel entry) =>
      _EntryMutation._(entry: entry, delete: false);

  factory _EntryMutation.delete() => const _EntryMutation._(delete: true);
}

String _formatHour(int hour) => '${hour.toString().padLeft(2, '0')}:00';
