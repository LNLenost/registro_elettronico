import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_elettronico/core/presentation/widgets/cusotm_placeholder.dart';
import 'package:registro_elettronico/feature/docente/data/docente_meetings_parser.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_experimental.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_widgets.dart';

/// Parent meetings (ricevimenti) of the teacher (EXPERIMENTAL: the mapped
/// account had no meeting slots): months as the grades chips,
/// then one card per meeting slot. Read only: creating, moving or cancelling
/// meetings stays on the web register.
class DocenteMeetingsPage extends StatefulWidget {
  final String path;
  final String title;

  const DocenteMeetingsPage({Key? key, required this.path, required this.title})
      : super(key: key);

  @override
  _DocenteMeetingsPageState createState() => _DocenteMeetingsPageState();
}

class _DocenteMeetingsPageState extends State<DocenteMeetingsPage> {
  String? _month;
  Future<DocenteMeetingsMonth>? _data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data ??= _fetch();
  }

  Future<DocenteMeetingsMonth> _fetch() {
    final scope = DocenteScope.of(context);
    final uri = Uri.parse(widget.path);
    final path = _month == null
        ? widget.path
        : uri.replace(queryParameters: {
            ...uri.queryParameters,
            'mese': _month!
          }).toString();
    return scope
        .guard(scope.api.getPage(path).then(parseDocenteMeetings).then((month) {
      debugPrint(
          '[DocenteMeetings] month=${month.selected} slots=${month.meetings.length}');
      return month;
    }));
  }

  Future<void> _refresh() async {
    final future = _fetch();
    setState(() => _data = future);
    await future.catchError((_) =>
        const DocenteMeetingsMonth(months: {}, selected: null, meetings: []));
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<DocenteMeetingsMonth>(
          future: _data,
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
              return const Center(child: CircularProgressIndicator());
            }
            final month = snapshot.data!;
            final keys = month.months.keys.toList();
            final selected = _month ?? month.selected;
            return ListView(
              children: [
                DocenteExperimentalBanner(
                    title: widget.title, path: widget.path),
                if (keys.isNotEmpty)
                  DocenteChips(
                    labels: [for (final k in keys) month.months[k]!],
                    selected: keys.indexOf(selected ?? ''),
                    onSelected: (i) {
                      _month = keys[i];
                      _refresh();
                    },
                  ),
                if (month.meetings.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 64),
                    child: CustomPlaceHolder(
                      icon: Icons.people,
                      text: docenteText(context, 'docente_meetings_empty'),
                      showUpdate: false,
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(children: [
                      for (final meeting in month.meetings)
                        DocenteCard(
                          title: meeting.day == null
                              ? meeting.date
                              : DateFormat('EEEE d MMMM', locale)
                                  .format(meeting.day!),
                          details: [
                            if (meeting.hour.isNotEmpty) '${meeting.hour}^',
                            meeting.text
                          ],
                          trailing: DocenteBadge(
                            '${meeting.parents}',
                            meeting.parents > 0
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.grey,
                          ),
                        ),
                    ]),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
