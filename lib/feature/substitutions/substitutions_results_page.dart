import 'package:flutter/material.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/feature/substitutions/data/sostituzioni_docenti_api.dart';

/// Native, read-only substitutions view backed by the teacher room.
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
  final SostituzioniDocentiApi _api = SostituzioniDocentiApi();
  List<Map<String, String>> _substitutions = const [];
  bool _loading = true;
  String? _errorKey;

  @override
  void initState() {
    super.initState();
    _loadSubstitutions();
  }

  Future<void> _loadSubstitutions() async {
    setState(() {
      _loading = true;
      _errorKey = null;
    });
    try {
      final substitutions = await _api.fetchToday(widget.schoolCode);
      if (mounted) setState(() => _substitutions = substitutions);
    } catch (_) {
      if (mounted) setState(() => _errorKey = 'substitutions_unreachable');
    } finally {
      if (mounted) setState(() => _loading = false);
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
            onPressed: _loading ? null : _loadSubstitutions,
            tooltip: trans.translate('substitutions_refresh'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorKey != null
              ? _Message(
                  text: trans.translate(_errorKey!)!,
                  action: _loadSubstitutions,
                  actionLabel: trans.translate('substitutions_retry')!,
                )
              : _substitutions.isEmpty
                  ? _Message(
                      text: trans.translate('substitutions_no_results')!,
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: _substitutions.map(_recordCard).toList(),
                    ),
    );
  }

  Widget _recordCard(Map<String, String> record) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: record.entries
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
