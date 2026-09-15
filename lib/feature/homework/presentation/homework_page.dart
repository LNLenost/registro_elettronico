import 'package:flutter/material.dart';
import 'package:registro_elettronico/core/infrastructure/app_injection.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/core/presentation/widgets/cusotm_placeholder.dart';
import 'package:registro_elettronico/feature/homework/data/homework_filters.dart';
import 'package:registro_elettronico/feature/homework/data/homework_remote_datasource.dart';

class HomeworkPage extends StatefulWidget {
  HomeworkPage({Key? key}) : super(key: key);

  @override
  _HomeworkPageState createState() => _HomeworkPageState();
}

class _HomeworkPageState extends State<HomeworkPage> {
  late Future<List<Homework>> _homeworks;
  HomeworkFilter _filter = HomeworkFilter.all;
  String _subject = '';

  @override
  void initState() {
    super.initState();
    _homeworks = _load();
  }

  Future<List<Homework>> _load() => sl<HomeworkRemoteDatasource>().getHomeworks();

  Future<void> _refresh() async {
    final request = _load();
    setState(() => _homeworks = request);
    await request;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.translate('homework')!)),
      body: FutureBuilder<List<Homework>>(
        future: _homeworks,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: TextButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.translate('refresh')!),
            ));
          }
          final homeworks = snapshot.data ?? const <Homework>[];
          if (homeworks.isEmpty) {
            return CustomPlaceHolder(
              text: AppLocalizations.of(context)!.translate('no_homework'),
              icon: Icons.assignment,
              showUpdate: true,
              onTap: _refresh,
            );
          }
          final subjects = homeworks.map((item) => item.subject).where((item) => item.isNotEmpty).toSet().toList()..sort();
          final source = sl<HomeworkRemoteDatasource>();
          final filtered = filterHomeworks(
            _subject.isEmpty ? homeworks : homeworks.where((item) => item.subject == _subject),
            _filter,
            DateTime.now(),
            source.getCompletedIds(),
          );
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                DropdownButton<String>(
                  isExpanded: true,
                  value: _subject,
                  items: [
                    const DropdownMenuItem(value: '', child: Text('Tutte le materie')),
                    ...subjects.map((item) => DropdownMenuItem(value: item, child: Text(item))),
                  ],
                  onChanged: (value) => setState(() => _subject = value ?? ''),
                ),
                Wrap(
                  spacing: 8,
                  children: HomeworkFilter.values.map((filter) => ChoiceChip(
                    label: Text(_filterLabel(filter)),
                    selected: _filter == filter,
                    onSelected: (_) => setState(() => _filter = filter),
                  )).toList(),
                ),
                const SizedBox(height: 8),
                ...filtered.map((homework) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _HomeworkCard(
                    homework: homework,
                    completed: source.getCompletedIds().contains(homework.id),
                    onToggleCompleted: () async {
                      await source.toggleCompleted(homework.id);
                      if (mounted) setState(() {});
                    },
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _filterLabel(HomeworkFilter filter) {
  switch (filter) {
    case HomeworkFilter.all: return 'Tutti';
    case HomeworkFilter.dueSoon: return 'In scadenza';
    case HomeworkFilter.expired: return 'Scaduti';
    case HomeworkFilter.completed: return 'Completati';
  }
}

class _HomeworkCard extends StatelessWidget {
  final Homework homework;
  final bool completed;
  final VoidCallback onToggleCompleted;

  const _HomeworkCard({Key? key, required this.homework, required this.completed, required this.onToggleCompleted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(
      leading: const Icon(Icons.assignment),
      title: Text(homework.subject),
      trailing: IconButton(
        icon: Icon(completed ? Icons.check_circle : Icons.radio_button_unchecked),
        onPressed: onToggleCompleted,
      ),
      subtitle: Text([homework.teacher, homework.instructions, homework.period]
          .where((value) => value.isNotEmpty).join('\n')),
    ));
  }
}
