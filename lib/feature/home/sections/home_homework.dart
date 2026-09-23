import 'package:flutter/material.dart';
import 'package:registro_elettronico/core/infrastructure/app_injection.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/feature/homework/data/homework_remote_datasource.dart';
import 'package:registro_elettronico/feature/homework/presentation/homework_page.dart';

class HomeHomework extends StatelessWidget {
  const HomeHomework({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: HomeworkRemoteDatasource.changes,
      builder: (_, __, ___) {
        final datasource = sl<HomeworkRemoteDatasource>();
        final completedIds = datasource.getCompletedIds();
        final items = datasource
            .getCachedHomeworks()
            .where((item) => !completedIds.contains(item.id))
            .toList()
          ..sort((a, b) => (a.deadline ?? DateTime(9999)).compareTo(b.deadline ?? DateTime(9999)));
        if (items.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(AppLocalizations.of(context)!.translate('homework')!),
            ...items.take(3).map((item) => Card(child: ListTile(
              leading: const Icon(Icons.assignment),
              title: Text(item.subject),
              subtitle: Text([item.instructions, item.period].where((value) => value.isNotEmpty).join(' · ')),
            ))),
            TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => HomeworkPage())),
              child: const Text('VEDI TUTTI'),
            ),
          ]),
        );
      },
    );
  }
}
