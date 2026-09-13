import 'package:flutter/material.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/feature/substitutions/data/myprof_api.dart';

/// Native, read-only MyProf substitutions view.
class SubstitutionsResultsPage extends StatefulWidget {
  final String schoolCode;

  const SubstitutionsResultsPage({
    Key? key,
    required this.schoolCode,
  }) : super(key: key);

  @override
  _SubstitutionsResultsPageState createState() =>
      _SubstitutionsResultsPageState();
}

class _SubstitutionsResultsPageState extends State<SubstitutionsResultsPage> {
  final MyProfApi _api = MyProfApi();
  final DateTime _date = DateTime.now();
  List<Map<String, dynamic>> _classes = const [];
  List<Map<String, dynamic>> _substitutions = const [];
  int? _classId;
  int? _hour;
  bool _loading = true;
  bool _loadingSubstitutions = false;
  String? _errorKey;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _loading = true;
      _errorKey = null;
      _classId = null;
      _hour = null;
      _substitutions = const [];
    });
    try {
      final school = await _api.initSchool(widget.schoolCode);
      if (school.expired || school.apiBase == null) {
        if (mounted) setState(() => _errorKey = 'substitutions_expired_code');
        return;
      }
      final classes = await _api.classesForDay(_date.weekday);
      if (mounted) setState(() => _classes = classes);
    } catch (_) {
      if (mounted) setState(() => _errorKey = 'substitutions_unreachable');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadSubstitutions(int classId, int hour) async {
    setState(() {
      _classId = classId;
      _hour = hour;
      _loadingSubstitutions = true;
      _substitutions = const [];
    });
    try {
      final substitutions = await _api.substitutionsForHour(
        id: classId,
        date: _date,
        hour: hour,
      );
      if (mounted) setState(() => _substitutions = substitutions);
    } catch (_) {
      if (mounted) setState(() => _errorKey = 'substitutions_unreachable');
    } finally {
      if (mounted) setState(() => _loadingSubstitutions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(trans.translate('substitutions_title')!),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadClasses,
            tooltip: trans.translate('substitutions_refresh'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorKey != null
              ? _Message(
                  text: trans.translate(_errorKey!)!,
                  action: _loadClasses,
                  actionLabel: trans.translate('substitutions_retry')!,
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      trans.translate('substitutions_today_classes')!,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(height: 8),
                    if (_classes.isEmpty)
                      _Message(text: trans.translate('substitutions_no_classes')!)
                    else
                      ..._classes.map((record) => _classTile(context, record)),
                    if (_classId != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        trans.translate('substitutions_select_hour')!,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          10,
                          (index) {
                            final hour = index + 1;
                            return ChoiceChip(
                              label: Text('$hour'),
                              selected: _hour == hour,
                              onSelected: (_) =>
                                  _loadSubstitutions(_classId!, hour),
                            );
                          },
                        ),
                      ),
                    ],
                    if (_hour != null) ...[
                      const SizedBox(height: 20),
                      if (_loadingSubstitutions)
                        const Center(child: CircularProgressIndicator())
                      else if (_substitutions.isEmpty)
                        _Message(
                          text: trans.translate('substitutions_no_results')!,
                        )
                      else
                        ..._substitutions.map(_recordCard),
                    ],
                  ],
                ),
    );
  }

  Widget _classTile(BuildContext context, Map<String, dynamic> record) {
    final trans = AppLocalizations.of(context)!;
    final id = MyProfApi.idFromRecord(record);
    return Card(
      child: ListTile(
        title: Text(_recordSummary(record)),
        subtitle: id == null
            ? Text(trans.translate('substitutions_missing_class_id')!)
            : null,
        trailing: const Icon(Icons.chevron_right),
        enabled: id != null,
        onTap: id == null
            ? null
            : () => setState(() {
                  _classId = id;
                  _hour = null;
                  _substitutions = const [];
                }),
      ),
    );
  }

  Widget _recordCard(Map<String, dynamic> record) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: record.entries
                .where((entry) => entry.value != null && entry.value != '')
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('${entry.key}: ${entry.value}'),
                  ),
                )
                .toList(),
          ),
        ),
      );

  String _recordSummary(Map<String, dynamic> record) {
    final values = record.entries
        .where((entry) => entry.key != 'id' && entry.value != null)
        .map((entry) => entry.value.toString())
        .where((value) => value.isNotEmpty)
        .take(3)
        .toList();
    return values.isEmpty ? '—' : values.join(' · ');
  }
}

class _Message extends StatelessWidget {
  final String text;
  final VoidCallback? action;
  final String? actionLabel;

  const _Message({
    Key? key,
    required this.text,
    this.action,
    this.actionLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(text, textAlign: TextAlign.center),
              if (action != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: action,
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      );
}
