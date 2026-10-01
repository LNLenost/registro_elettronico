import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:intl/intl.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/feature/docente/data/docente_classes_parser.dart';
import 'package:registro_elettronico/feature/docente/data/docente_journal_parser.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';

/// Teacher journal of a class and subject, as the student lessons page:
/// search bar, month headers and lesson cards (topic, then details).
class DocenteJournalPage extends StatefulWidget {
  final DocenteLink link;
  final String title;

  const DocenteJournalPage({Key? key, required this.link, required this.title})
      : super(key: key);

  @override
  _DocenteJournalPageState createState() => _DocenteJournalPageState();
}

class _DocenteJournalPageState extends State<DocenteJournalPage> {
  late SearchBar _searchBar;
  String _query = '';
  Future<List<DocenteJournalLesson>>? _lessons;

  @override
  void initState() {
    super.initState();
    _searchBar = SearchBar(
      setState: setState,
      onChanged: (query) => setState(() => _query = query),
      buildDefaultAppBar: (context) => AppBar(
        title: Text(widget.title),
        actions: [_searchBar.getSearchAction(context)],
      ),
      onClosed: () => setState(() => _query = ''),
      onCleared: () => setState(() => _query = ''),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lessons ??= _fetch();
  }

  Future<List<DocenteJournalLesson>> _fetch() {
    final scope = DocenteScope.of(context);
    return scope.guard(scope.api
        .getPage(widget.link.path)
        .then(parseDocenteJournal)
        .then((lessons) {
      debugPrint(
          '[DocenteJournal] lessons=${lessons.length} withTopic=${lessons.where((l) => l.topic.isNotEmpty).length}');
      return lessons;
    }));
  }

  Future<void> _refresh() async {
    final future = _fetch();
    setState(() => _lessons = future);
    await future.catchError((_) => <DocenteJournalLesson>[]);
  }

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    final month = DateFormat('MMMM yyyy', trans.locale.toString());
    return Scaffold(
      appBar: _searchBar.build(context),
      body: DocenteAsyncView<List<DocenteJournalLesson>>(
        future: _lessons,
        onRefresh: _refresh,
        isEmpty: (lessons) => lessons.isEmpty,
        emptyText: trans.translate('no_lessons')!,
        emptyIcon: Icons.subject,
        builder: (lessons) {
          final query = _query.toLowerCase();
          final shown = lessons
              .where((l) =>
                  query.isEmpty ||
                  '${l.activity} ${l.topic} ${l.teacher}'
                      .toLowerCase()
                      .contains(query))
              .toList();
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: shown.length,
            itemBuilder: (context, i) {
              final lesson = shown[i];
              final day = lesson.day;
              final newMonth = day != null &&
                  (i == 0 ||
                      shown[i - 1].day == null ||
                      shown[i - 1].day!.month != day.month ||
                      shown[i - 1].day!.year != day.year);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (newMonth)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      child: Text(month.format(day!),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary)),
                    ),
                  Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              lesson.topic.isNotEmpty
                                  ? lesson.topic
                                  : lesson.activity,
                              style: const TextStyle(fontSize: 15)),
                          const SizedBox(height: 8),
                          Text(
                            [
                              lesson.teacher,
                              lesson.activity,
                              '${lesson.date} ${lesson.hour}'.trim()
                            ].where((s) => s.isNotEmpty).join(' - '),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
