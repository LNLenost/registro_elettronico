import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/utils/constants/preferences_constants.dart';
import 'package:registro_elettronico/utils/navigation_config.dart';

class NavigationSettingsPage extends StatefulWidget {
  const NavigationSettingsPage({Key? key}) : super(key: key);

  @override
  _NavigationSettingsPageState createState() => _NavigationSettingsPageState();
}

class _NavigationSettingsPageState extends State<NavigationSettingsPage> {
  List<String> _order = NavigationConfig.defaultOrder;
  List<String> _hidden = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final order = NavigationConfig.normalizeOrder(
      prefs.getStringList(PrefsConstants.navigationOrder),
    );
    if (!mounted) return;
    setState(() {
      _order = order;
      _hidden = NavigationConfig.normalizeHidden(
        order,
        prefs.getStringList(PrefsConstants.navigationHidden),
      );
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(PrefsConstants.navigationOrder, _order);
    await prefs.setStringList(
      PrefsConstants.navigationHidden,
      NavigationConfig.normalizeHidden(_order, _hidden),
    );
  }

  String _label(BuildContext context, String id) {
    final trans = AppLocalizations.of(context)!;
    return {
      NavigationConfig.home: trans.translate('home'),
      NavigationConfig.grades: trans.translate('grades'),
      NavigationConfig.agenda: trans.translate('agenda'),
      NavigationConfig.noticeboard: trans.translate('notice_board'),
      NavigationConfig.more: trans.translate('more_page'),
    }[id]!;
  }

  IconData _icon(String id) {
    return {
      NavigationConfig.home: Icons.home,
      NavigationConfig.grades: Icons.class_,
      NavigationConfig.agenda: Icons.today,
      NavigationConfig.noticeboard: Icons.email,
      NavigationConfig.more: Icons.more_horiz,
    }[id]!;
  }

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(trans.translate('customize_navigation_title')!),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(trans.translate('customize_navigation_subtitle')!),
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
