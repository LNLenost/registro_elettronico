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
            return _WeeklyTimetable(entries: state.timetableData.entries);
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
  final List<TimetableEntryDomainModel> entries;

  const _WeeklyTimetable({required this.entries});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Orario settimanale'),
            const SizedBox(height: 4),
            Text(
              'Aggiungi materie e orari manualmente. Non sono associate a date.',
              style: Theme.of(context).textTheme.bodyText2,
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  _weekdays.length,
                  (day) => SizedBox(
                    width: (constraints.maxWidth / 3).clamp(140.0, 190.0).toDouble(),
                    child: _DayColumn(
                      day: day,
                      entries: entries
                          .where((entry) => entry.dayOfWeek == day)
                          .toList()
                        ..sort((a, b) => a.startHour.compareTo(b.startHour)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  final int day;
  final List<TimetableEntryDomainModel> entries;

  const _DayColumn({required this.day, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _weekdays[day],
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Aggiungi lezione',
                  onPressed: () => _editEntry(context, day: day),
                ),
              ],
            ),
            const Divider(height: 1),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Nessuna lezione'),
              ),
            for (final entry in entries)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(entry.subjectName ?? 'Materia'),
                subtitle: Text(
                  '${_formatHour(entry.startHour)} – ${_formatHour(entry.endHour)}',
                ),
                onTap: () => _editEntry(context, entry: entry),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _editEntry(
    BuildContext context, {
    int? day,
    TimetableEntryDomainModel? entry,
  }) async {
    final mutation = await showDialog<_EntryMutation>(
      context: context,
      builder: (_) => _EntryEditorDialog(entry: entry, initialDay: day),
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
}

class _EntryEditorDialog extends StatefulWidget {
  final TimetableEntryDomainModel? entry;
  final int? initialDay;

  const _EntryEditorDialog({this.entry, this.initialDay});

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
    _startHour = entry?.startHour ?? 8;
    _endHour = entry?.endHour ?? 9;
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
        ElevatedButton(
          onPressed: _save,
          child: const Text('Salva'),
        ),
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
