import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/feature/substitutions/data/myprof_api.dart';
import 'package:registro_elettronico/feature/web/presentation/spaggiari_web_view.dart';

/// Metodo C: apre il portale ufficiale in WebView dopo aver salvato il codice.
/// ponytail: non duplico un portale esterno finché non esiste un'API pubblica.
class SubstitutionsPage extends StatefulWidget {
  const SubstitutionsPage({Key? key}) : super(key: key);

  @override
  _SubstitutionsPageState createState() => _SubstitutionsPageState();
}

class _SubstitutionsPageState extends State<SubstitutionsPage> {
  static const _schoolCodeKey = 'substitutions_school_code';
  static const _portalUrl = 'https://www.sostituzionidocenti.net/web/';
  final _controller = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCode();
  }

  Future<void> _loadCode() async {
    final prefs = await SharedPreferences.getInstance();
    _controller.text = prefs.getString(_schoolCodeKey) ?? '';
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveAndOpen() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .translate('substitutions_empty_code')!),
        ),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_schoolCodeKey, code);
    try {
      final result = await MyProfApi().initSchool(code);
      if (result.expired && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!
                .translate('substitutions_expired_code')!),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!
                .translate('substitutions_unreachable')!),
          ),
        );
      }
    }
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SpaggiariWebView(
        appBarTitle: AppLocalizations.of(context)!
            .translate('substitutions_title'),
        url: _portalUrl,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!
            .translate('substitutions_title')!),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(AppLocalizations.of(context)!
              .translate('substitutions_description')!),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\\s'))],
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!
                  .translate('substitutions_school_code'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _saveAndOpen,
            icon: const Icon(Icons.open_in_browser),
            label: Text(AppLocalizations.of(context)!
                .translate('substitutions_open_button')!),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
