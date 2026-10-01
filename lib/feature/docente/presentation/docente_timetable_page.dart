import 'package:flutter/material.dart';
import 'package:registro_elettronico/core/presentation/widgets/cusotm_placeholder.dart';
import 'package:registro_elettronico/feature/docente/data/docente_timetable_parser.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_experimental.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_widgets.dart';
import 'package:registro_elettronico/feature/timetable/presentation/timetable_page.dart';

/// Teacher timetable (EXPERIMENTAL, inferred parser), drawn as the student
/// timetable grid: days as columns, hours in the left gutter, one coloured
/// block per lesson. Periods of the page as chips.
class DocenteTimetablePage extends StatefulWidget {
  final String path;
  final String title;

  const DocenteTimetablePage(
      {Key? key, required this.path, required this.title})
      : super(key: key);

  @override
  _DocenteTimetablePageState createState() => _DocenteTimetablePageState();
}

class _DocenteTimetablePageState extends State<DocenteTimetablePage> {
  String? _period;
  Future<DocenteTimetable>? _data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data ??= _fetch();
  }

  /// The period form of the page is a GET with `periodo` and `ope=docente`.
  String get _path => _period == null
      ? widget.path
      : Uri.parse(widget.path).replace(queryParameters: {
          'periodo': _period!,
          'ope': 'docente',
        }).toString();

  Future<DocenteTimetable> _fetch() {
    final scope = DocenteScope.of(context);
    return scope
        .guard(scope.api.getPage(_path).then(parseDocenteTimetable).then((t) {
      debugPrint('[DocenteTimetable] days=${t.days.length} '
          'hours=${t.hours.length} slots=${t.slots.length} '
          'periods=${t.periods.length}');
      return t;
    }));
  }

  Future<void> _refresh() async {
    final future = _fetch();
    setState(() => _data = future);
    await future.catchError((_) => const DocenteTimetable(
        days: [], hours: [], slots: [], periods: {}, selectedPeriod: null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: DocenteAsyncView<DocenteTimetable>(
        future: _data,
        isEmpty: (_) => false,
        emptyText: '',
        onRefresh: _refresh,
        builder: (timetable) {
          final periods = timetable.periods.keys.toList();
          final selected = _period ?? timetable.selectedPeriod;
          return ListView(
            children: [
              DocenteExperimentalBanner(title: widget.title, path: _path),
              if (periods.length > 1)
                DocenteChips(
                  labels: [for (final p in periods) timetable.periods[p]!],
                  selected: periods.indexOf(selected ?? ''),
                  onSelected: (i) {
                    _period = periods[i];
                    _refresh();
                  },
                ),
              if (timetable.slots.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: CustomPlaceHolder(
                    icon: Icons.access_time,
                    text: docenteText(context, 'docente_timetable_empty'),
                    showUpdate: false,
                  ),
                )
              else
                _Grid(timetable: timetable),
            ],
          );
        },
      ),
    );
  }
}

/// Read-only copy of the student grid (timetable_page.dart `_Grid`).
class _Grid extends StatelessWidget {
  final DocenteTimetable timetable;

  const _Grid({required this.timetable});

  static const _h = 72.0, _w = 145.0, _gutter = 38.0;
  static const _line = BorderSide(color: Colors.black, width: .8);

  Widget _box(double width, double height, Widget? child) => Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
            border: Border(right: _line, bottom: _line, top: _line)),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    final days = timetable.days.isNotEmpty
        ? timetable.days
        : List.filled(
            timetable.slots.map((s) => s.day).reduce((a, b) => a > b ? a : b) +
                1,
            '');
    final hours = timetable.hours;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(children: [
          Row(children: [
            const SizedBox(width: _gutter),
            for (final day in days)
              _box(
                  _w,
                  28,
                  Text(day.length > 3 ? day.substring(0, 3) : day,
                      style: const TextStyle(fontSize: 11))),
          ]),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(children: [
              for (var i = 0; i < hours.length; i++)
                Container(
                  width: _gutter,
                  height: _h,
                  alignment: Alignment.center,
                  decoration:
                      const BoxDecoration(border: Border(bottom: _line)),
                  child: Text(
                      hours[i].isNotEmpty
                          ? hours[i].replaceFirst(' ', '\n')
                          : '${i + 1}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 9)),
                ),
            ]),
            SizedBox(
              width: _w * days.length,
              height: _h * hours.length,
              child: Stack(children: [
                Row(children: [
                  for (var d = 0; d < days.length; d++)
                    Column(children: [
                      for (var h = 0; h < hours.length; h++) _box(_w, _h, null)
                    ]),
                ]),
                for (final slot in timetable.slots)
                  if (slot.day < days.length)
                    Positioned(
                      left: slot.day * _w,
                      top: slot.hour * _h,
                      width: _w,
                      height: slot.span * _h,
                      child: Material(
                        color: timetableColorForSubject(slot.lines.first),
                        child: Container(
                          decoration: const BoxDecoration(
                              border: Border.fromBorderSide(_line)),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(slot.lines.first,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black)),
                              for (final line in slot.lines.skip(1).take(2))
                                Text(line,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 9,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black)),
                            ],
                          ),
                        ),
                      ),
                    ),
              ]),
            ),
          ]),
        ]),
      ),
    );
  }
}
