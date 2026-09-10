import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:registro_elettronico/core/infrastructure/app_injection.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/feature/agenda/presentation/agenda_page.dart';
import 'package:registro_elettronico/feature/grades/presentation/grades_page.dart';
import 'package:registro_elettronico/feature/home/home_page.dart';
import 'package:registro_elettronico/feature/navigator/more_page.dart';
import 'package:registro_elettronico/feature/noticeboard/presentation/noticeboard_page.dart';
import 'package:registro_elettronico/utils/constants/preferences_constants.dart';
import 'package:registro_elettronico/utils/navigation_config.dart';
import 'package:registro_elettronico/utils/update_manager.dart';

class NavigatorPage extends StatefulWidget {
  final bool fromLogin;

  NavigatorPage({
    Key? key,
    this.fromLogin = false,
  }) : super(key: key);

  @override
  _NavigatorPageState createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage> {
  String _currentPage = NavigationConfig.home;
  List<String> _navigationOrder = NavigationConfig.defaultOrder;
  List<String> _hiddenNavigationItems = const [];
  late List<Widget> _pages;
  SRUpdateManager? srUpdateManager;

  @override
  void initState() {
    srUpdateManager = sl();
    unawaited(srUpdateManager!.checkForUpdates());
    _pages = _buildPages();
    _loadNavigationConfig();
    super.initState();
  }

  List<Widget> _buildPages() {
    return [
      HomePage(fromLogin: widget.fromLogin),
      GradesPage(),
      AgendaPage(),
      NoticeboardPage(),
      MorePage(onNavigationChanged: _loadNavigationConfig),
    ];
  }

  Future<void> _loadNavigationConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final order = NavigationConfig.normalizeOrder(
      prefs.getStringList(PrefsConstants.navigationOrder),
    );
    final hidden = NavigationConfig.normalizeHidden(
      order,
      prefs.getStringList(PrefsConstants.navigationHidden),
    );
    if (!mounted) return;
    setState(() {
      _navigationOrder = order;
      _hiddenNavigationItems = hidden;
      if (!NavigationConfig.visibleItems(order, hidden).contains(_currentPage)) {
        _currentPage = NavigationConfig.visibleItems(order, hidden).first;
      }
    });
  }

  List<String> get _visibleNavigationItems => NavigationConfig.visibleItems(
        _navigationOrder,
        _hiddenNavigationItems,
      );

  int get _currentPageIndex => NavigationConfig.defaultOrder.indexOf(_currentPage);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: IndexedStack(
        index: _currentPageIndex,
        children: _pages,
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).cardTheme.color,
      type: BottomNavigationBarType.fixed,
      currentIndex: _visibleNavigationItems.indexOf(_currentPage),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) {
        final page = _visibleNavigationItems[index];
        if (_currentPage == page) {
          _refreshPage(page);
        }
        setState(() => _currentPage = page);
      },
      items: _visibleNavigationItems.map(_navigationItem).toList(),
    );
  }

  BottomNavigationBarItem _navigationItem(String id) {
    final trans = AppLocalizations.of(context)!;
    final labels = {
      NavigationConfig.home: trans.translate('home'),
      NavigationConfig.grades: trans.translate('grades'),
      NavigationConfig.agenda: trans.translate('agenda'),
      NavigationConfig.noticeboard: trans.translate('notice_board'),
      NavigationConfig.more: trans.translate('more_page'),
    };
    final icons = {
      NavigationConfig.home: Icons.home,
      NavigationConfig.grades: Icons.class_,
      NavigationConfig.agenda: Icons.today,
      NavigationConfig.noticeboard: Icons.email,
      NavigationConfig.more: Icons.more_horiz,
    };
    return BottomNavigationBarItem(
      label: labels[id],
      icon: Icon(icons[id]),
    );
  }

  void _refreshPage(String page) {
    if (page == NavigationConfig.home && homeRefresherKey.currentState != null) {
      homeRefresherKey.currentState!.show();
    } else if (page == NavigationConfig.agenda) {
      srUpdateManager!.updateAgendaData(context);
    } else if (page == NavigationConfig.grades &&
        gradesRefresherKey.currentState != null) {
      gradesRefresherKey.currentState!.show();
    } else if (page == NavigationConfig.noticeboard &&
        noticeboardRefresherKey.currentState != null) {
      noticeboardRefresherKey.currentState!.show();
    }
  }

  void goToGradesPage() {
    setState(() => _currentPage = NavigationConfig.grades);
  }
}
