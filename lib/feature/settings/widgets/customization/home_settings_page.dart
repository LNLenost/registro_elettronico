import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/utils/constants/preferences_constants.dart';
import 'package:registro_elettronico/utils/home_config.dart';

class HomeSettingsPage extends StatefulWidget {
  const HomeSettingsPage({Key? key}) : super(key: key);

  @override
  _HomeSettingsPageState createState() => _HomeSettingsPageState();
}

class _HomeSettingsPageState extends State<HomeSettingsPage> {
  List<String> _order = HomeConfig.items.toList();
  List<String> _hidden = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final order = HomeConfig.normalizeOrder(
      prefs.getStringList(PrefsConstants.homeOrder),
    );
    if (!mounted) return;
    setState(() {
      _order = order;
      _hidden = HomeConfig.normalizeHidden(
        order,
        prefs.getStringList(PrefsConstants.homeHidden),
      );
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(PrefsConstants.homeOrder, _order);
    await prefs.setStringList(
      PrefsConstants.homeHidden,
      HomeConfig.normalizeHidden(_order, _hidden),
    );
    HomeConfig.notifyChanged();
  }

  String _label(BuildContext context, String id) {
    final trans = AppLocalizations.of(context)!;
    return {
      HomeConfig.actions: trans.translate('home_actions'),
      HomeConfig.grades: trans.translate('last_grades'),
      HomeConfig.lessons: trans.translate('last_lessons'),
      HomeConfig.agenda: trans.translate('next_events'),
    }[id]!;
  }

  IconData _icon(String id) {
    return {
      HomeConfig.actions: Icons.flash_on,
      HomeConfig.grades: Icons.assessment,
      HomeConfig.lessons: Icons.book,
      HomeConfig.agenda: Icons.today,
    }[id]!;
  }

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(trans.translate('customize_home_title')!)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(trans.translate('customize_home_subtitle')!),
          ),
          Expanded(
            child: ReorderableListView(
              padding: const EdgeInsets.only(bottom: 16),
              onReorder: (oldIndex, newIndex) async {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = _order.removeAt(oldIndex);
                _order.insert(newIndex, item);
                await _save();
                setState(() {});
              },
              children: _order.map((id) {
                final visible = !_hidden.contains(id);
                final visibleCount = _order.length - _hidden.length;
                return SwitchListTile(
                  key: ValueKey(id),
                  secondary: Icon(_icon(id)),
                  title: Text(_label(context, id)),
                  value: visible,
                  onChanged: visible && visibleCount == 1
                      ? null
                      : (value) async {
                          setState(() {
                            if (value) {
                              _hidden = _hidden.where((item) => item != id).toList();
                            } else {
                              _hidden = [..._hidden, id];
                            }
                          });
                          await _save();
                        },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
