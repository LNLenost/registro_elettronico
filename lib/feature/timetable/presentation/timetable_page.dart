import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:registro_elettronico/core/infrastructure/app_injection.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/core/presentation/custom/states/sr_failure_view.dart';
import 'package:registro_elettronico/core/presentation/custom/states/sr_loading_view.dart';
import 'package:registro_elettronico/feature/timetable/domain/model/timetable_entry_domain_model.dart';
import 'package:registro_elettronico/feature/timetable/domain/repository/timetable_repository.dart';
import 'package:registro_elettronico/feature/timetable/presentation/watcher/timetable_watcher_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _days = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab'];
const _colors = [Color(0xffddc87c), Color(0xffcfa287), Color(0xffebd8c4), Color(0xff96b4c0), Color(0xffd8e6ef), Color(0xffc6dee9), Color(0xffd88579), Color(0xfff3f0e4), Color(0xffc5bfa2)];
const _colorsKey = 'timetable_subject_colors';
const _timesKey = 'timetable_period_starts';

String _key(String name) => name.trim().toLowerCase();
List<int> _defaultTimes() => List.generate(10, (i) => 480 + i * 60);
List<int> _periodTimes() {
  final raw = sl<SharedPreferences>().getString(_timesKey);
  try { final list = (json.decode(raw ?? '') as List).cast<num>().map((v) => v.toInt()).toList(); return list.length == 10 ? list : _defaultTimes(); } catch (_) { return _defaultTimes(); }
}
Map<String, int> _savedColors() {
  try { return (json.decode(sl<SharedPreferences>().getString(_colorsKey) ?? '{}') as Map).map((k, v) => MapEntry(k.toString(), (v as num).toInt())); } catch (_) { return {}; }
}
Color timetableColorForSubject(String? subject) => Color(_savedColors()[_key(subject ?? '')] ?? _colors[(subject ?? '').hashCode.abs() % _colors.length].value);
String _time(int minutes) => '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

class TimetablePage extends StatefulWidget { const TimetablePage({Key? key}) : super(key: key); @override State<TimetablePage> createState() => _TimetablePageState(); }
class _TimetablePageState extends State<TimetablePage> {
  @override void initState() { super.initState(); BlocProvider.of<TimetableWatcherBloc>(context).add(TimetableStartWatcherIfNeeded()); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(AppLocalizations.of(context)!.translate('timetable')!), actions: [IconButton(icon: const Icon(Icons.schedule), tooltip: 'Orari', onPressed: _editPeriodTimes)]), body: BlocBuilder<TimetableWatcherBloc, TimetableWatcherState>(builder: (context, state) {
    if (state is TimetableWatcherLoadSuccess) return _Grid(className: state.timetableData.className, entries: state.timetableData.entries);
    if (state is TimetableWatcherFailure) return SRFailureView(failure: state.failure, refresh: () async => BlocProvider.of<TimetableWatcherBloc>(context).add(TimetableStartWatcherIfNeeded()));
    return SRLoadingView();
  }));
  Future<void> _editPeriodTimes() async {
    final result = await showDialog<List<int>>(context: context, builder: (_) => _PeriodTimesDialog(times: _periodTimes()));
    if (result != null) { await sl<SharedPreferences>().setString(_timesKey, json.encode(result)); setState(() {}); }
  }
}

class _Grid extends StatelessWidget {
  final String? className; final List<TimetableEntryDomainModel> entries;
  const _Grid({this.className, required this.entries});
  @override Widget build(BuildContext context) {
    final times = _periodTimes(); const h = 72.0, w = 145.0;
    return SingleChildScrollView(padding: const EdgeInsets.fromLTRB(12, 24, 12, 12), child: Column(children: [Text((className?.isNotEmpty == true ? className : 'CLASSE')!.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 12), SingleChildScrollView(scrollDirection: Axis.horizontal, child: Column(children: [Row(children: [const SizedBox(width: 38), for (final d in _days) _box(w, 28, Text(d, style: const TextStyle(fontSize: 11)))]), Row(crossAxisAlignment: CrossAxisAlignment.start, children: [_Gutter(times: times, height: h), SizedBox(width: w * 6, height: h * 10, child: Stack(children: [_Background(times: times, width: w, height: h), for (final e in entries.where((e) => e.hasValidTimeRange)) _block(context, e, times, w, h)])])])])])));
  }
  Widget _block(BuildContext context, TimetableEntryDomainModel e, List<int> times, double w, double h) {
    final start = _index(times, e.startMinutes); final end = max(start + 1, _index(times, e.endMinutes));
    return Positioned(left: e.dayOfWeek! * w, top: start * h, width: w, height: (end - start) * h, child: Material(color: timetableColorForSubject(e.subjectName), child: InkWell(onTap: () => _edit(context, entry: e), child: Container(decoration: const BoxDecoration(border: Border.fromBorderSide(BorderSide(color: Colors.black, width: .8))), alignment: Alignment.center, padding: const EdgeInsets.all(5), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(e.subjectName ?? 'Materia', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)), Text('${_time(e.startMinutes)} – ${_time(e.endMinutes)}', style: const TextStyle(fontSize: 9, fontStyle: FontStyle.italic))]))));
  }
  int _index(List<int> times, int value) { for (var i = times.length - 1; i >= 0; i--) { if (value >= times[i]) return i; } return 0; }
}
class _Background extends StatelessWidget { final List<int> times; final double width, height; const _Background({required this.times, required this.width, required this.height}); @override Widget build(BuildContext context) => Row(children: List.generate(6, (day) => Column(children: List.generate(10, (row) => GestureDetector(onTap: () => _edit(context, day: day, start: times[row], end: row == 9 ? times[row] + 60 : times[row + 1]), child: _box(width, height, null)))))); }
class _Gutter extends StatelessWidget { final List<int> times; final double height; const _Gutter({required this.times, required this.height}); @override Widget build(BuildContext context) => Column(children: List.generate(10, (i) => Container(width: 38, height: height, alignment: Alignment.center, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black, width: .8))), child: Text('${i + 1}\n${_time(times[i])}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 9))))); }
Widget _box(double w, double h, Widget? child) => Container(width: w, height: h, alignment: Alignment.center, decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.black, width: .8), bottom: BorderSide(color: Colors.black, width: .8), top: BorderSide(color: Colors.black, width: .8))), child: child);

Future<void> _edit(BuildContext context, {int? day, int? start, int? end, TimetableEntryDomainModel? entry}) async {
  final mutation = await showDialog<_Mutation>(context: context, builder: (_) => _EntryDialog(entry: entry, day: day, start: start, end: end)); if (mutation == null) return;
  if (mutation.color != null && mutation.entry != null) { final colors = _savedColors()..[_key(mutation.entry!.subjectName!)] = mutation.color!.value; await sl<SharedPreferences>().setString(_colorsKey, json.encode(colors)); }
  final repo = sl<TimetableRepository>(); final result = mutation.delete ? await repo.deleteTimetableEntry(id: entry!.id!) : entry == null ? await repo.insertTimetableEntry(entry: mutation.entry!) : await repo.updateTimetableEntry(entry: mutation.entry!);
  result.fold((_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossibile salvare l’orario'))), (_) {});
}
class _EntryDialog extends StatefulWidget { final TimetableEntryDomainModel? entry; final int? day, start, end; const _EntryDialog({this.entry, this.day, this.start, this.end}); @override State<_EntryDialog> createState() => _EntryDialogState(); }
class _EntryDialogState extends State<_EntryDialog> { late TextEditingController name; late int day, start, end; late Color color; String? error;
  @override void initState() { super.initState(); final e = widget.entry; final times = _periodTimes(); name = TextEditingController(text: e?.subjectName ?? ''); day = e?.dayOfWeek ?? widget.day ?? 0; start = e?.startMinutes ?? widget.start ?? times.first; end = e?.endMinutes ?? widget.end ?? times[1]; color = timetableColorForSubject(e?.subjectName); }
  @override void dispose() { name.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) { final times = _periodTimes(); final ends = [...times.skip(1), times.last + 60]; return AlertDialog(title: Text(widget.entry == null ? 'Aggiungi lezione' : 'Modifica lezione'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'Materia')), _select('Giorno', day, List.generate(6, (i) => DropdownMenuItem(value: i, child: Text(_days[i]))), (v) => day = v), _select('Dalle', start, times.map((v) => DropdownMenuItem(value: v, child: Text(_time(v)))).toList(), (v) => start = v), _select('Alle', end, ends.map((v) => DropdownMenuItem(value: v, child: Text(_time(v)))).toList(), (v) => end = v), ListTile(title: const Text('Colore'), trailing: CircleAvatar(backgroundColor: color), onTap: _pickColor), if (error != null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error))])), actions: [if (widget.entry != null) TextButton(onPressed: () => Navigator.pop(context, _Mutation.delete()), child: const Text('Elimina')), TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')), ElevatedButton(onPressed: _save, child: const Text('Salva'))]); }
  Widget _select(String label, int value, List<DropdownMenuItem<int>> items, void Function(int) set) => Padding(padding: const EdgeInsets.only(top: 12), child: DropdownButtonFormField<int>(value: value, decoration: InputDecoration(labelText: label), items: items, onChanged: (v) => setState(() => set(v!))));
  Future<void> _pickColor() async { await showDialog(context: context, builder: (_) => AlertDialog(content: MaterialPicker(pickerColor: color, onColorChanged: (v) { setState(() => color = v); Navigator.pop(context); }))); }
  void _save() { if (name.text.trim().isEmpty || end <= start) { setState(() => error = 'Inserisci materia e orario valido.'); return; } Navigator.pop(context, _Mutation.save(TimetableEntryDomainModel.manual(id: widget.entry?.id, dayOfWeek: day, subjectName: name.text.trim(), startMinutes: start, endMinutes: end), color)); }
}
class _Mutation { final TimetableEntryDomainModel? entry; final Color? color; final bool delete; const _Mutation._({this.entry, this.color, required this.delete}); factory _Mutation.save(TimetableEntryDomainModel e, Color c) => _Mutation._(entry: e, color: c, delete: false); factory _Mutation.delete() => const _Mutation._(delete: true); }
class _PeriodTimesDialog extends StatefulWidget { final List<int> times; const _PeriodTimesDialog({required this.times}); @override State<_PeriodTimesDialog> createState() => _PeriodTimesDialogState(); }
class _PeriodTimesDialogState extends State<_PeriodTimesDialog> { late List<int> times; @override void initState() { super.initState(); times = [...widget.times]; } @override Widget build(BuildContext context) => AlertDialog(title: const Text('Orari delle ore'), content: SizedBox(width: 260, height: 430, child: ListView.builder(itemCount: 10, itemBuilder: (_, i) => ListTile(title: Text('${i + 1}ª ora'), trailing: Text(_time(times[i])), onTap: () async { final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: times[i] ~/ 60, minute: times[i] % 60)); if (t != null) setState(() => times[i] = t.hour * 60 + t.minute); }))), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')), ElevatedButton(onPressed: () { final sorted = [...times]..sort(); if (sorted.toString() == times.toString()) Navigator.pop(context, times); }, child: const Text('Salva'))]); }
