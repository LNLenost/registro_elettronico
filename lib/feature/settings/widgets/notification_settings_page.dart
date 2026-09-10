import 'package:flutter/material.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/utils/constants/preferences_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) setState(() => _prefs = prefs);
    });
  }

  Future<void> _set(String key, bool value) async {
    await _prefs!.setBool(key, value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    if (_prefs == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text(trans.translate('notifications')!)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(trans.translate('choose_what_to_notify')!),
          ),
          _tile(trans.translate('grades')!, PrefsConstants.gradesNotifications),
          _tile(trans.translate('notice_board')!, PrefsConstants.noticesNotifications),
          _tile(trans.translate('notes')!, PrefsConstants.notesNotifications),
          _tile(trans.translate('absences')!, PrefsConstants.absencesNotifications),
        ],
      ),
    );
  }

  Widget _tile(String title, String key) {
    return SwitchListTile(
      title: Text(title),
      value: _prefs!.getBool(key) ?? false,
      onChanged: (value) => _set(key, value),
    );
  }
}
