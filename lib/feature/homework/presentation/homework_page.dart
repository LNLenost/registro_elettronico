import 'package:flutter/material.dart';
import 'package:registro_elettronico/core/infrastructure/app_injection.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/core/presentation/widgets/cusotm_placeholder.dart';
import 'package:registro_elettronico/feature/homework/data/homework_remote_datasource.dart';

class HomeworkPage extends StatefulWidget {
  HomeworkPage({Key? key}) : super(key: key);

  @override
  _HomeworkPageState createState() => _HomeworkPageState();
}

class _HomeworkPageState extends State<HomeworkPage> {
  late Future<List<Homework>> _homeworks;

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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('homework')!),
      ),
      body: FutureBuilder<List<Homework>>(
        future: _homeworks,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: TextButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.translate('refresh')!),
              ),
            );
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
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: homeworks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (_, index) => _HomeworkCard(homework: homeworks[index]),
            ),
          );
        },
      ),
    );
  }
}

class _HomeworkCard extends StatelessWidget {
  final Homework homework;

  const _HomeworkCard({Key? key, required this.homework}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.assignment),
        title: Text(homework.subject),
        subtitle: Text(
          [homework.teacher, homework.instructions, homework.period]
              .where((value) => value.isNotEmpty)
              .join('\n'),
        ),
      ),
    );
  }
}