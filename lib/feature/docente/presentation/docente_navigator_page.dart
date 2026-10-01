import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:registro_elettronico/core/infrastructure/app_injection.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/feature/authentication/data/datasource/registry_provider_preferences.dart';
import 'package:registro_elettronico/feature/authentication/presentation/registry_provider_page.dart';
import 'package:registro_elettronico/feature/docente/data/docente_classes_parser.dart';
import 'package:registro_elettronico/feature/docente/data/docente_session_store.dart';
import 'package:registro_elettronico/feature/docente/data/docente_web_api.dart';
import 'package:registro_elettronico/feature/docente/data/webview_cookies.dart';
import 'package:registro_elettronico/feature/docente/domain/docente_sections.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_agenda_tab.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_class_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_classes_tab.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_dashboard_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_login_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_more_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_noticeboard_tab.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_service_router.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_web_page.dart';

/// Root of the teacher area, with the same bottom navigation as the student
/// area (feature/navigator/navigator_page.dart): icons only, pages kept in an
/// IndexedStack, tapping the current tab again refreshes it.
class DocenteNavigatorPage extends StatefulWidget {
  const DocenteNavigatorPage({Key? key}) : super(key: key);

  @override
  _DocenteNavigatorPageState createState() => _DocenteNavigatorPageState();
}

final docenteHomeRefresherKey = GlobalKey<RefreshIndicatorState>();
final docenteClassesRefresherKey = GlobalKey<RefreshIndicatorState>();
final docenteAgendaRefresherKey = GlobalKey<RefreshIndicatorState>();
final docenteNoticeboardRefresherKey = GlobalKey<RefreshIndicatorState>();

class _DocenteNavigatorPageState extends State<DocenteNavigatorPage> {
  final _store = DocenteSessionStore(sl());
  final _classesTabKey = GlobalKey<DocenteClassesTabState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  DocenteSession? _session;
  DocenteWebApi? _api;
  DocenteTab _tab = DocenteTab.home;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final session = await _store.read();
    if (session == null) return _expired();
    setState(() {
      _session = session;
      _api = DocenteWebApi.forSession(
          sessionId: session.sessionId, userAgent: session.userAgent);
    });
    if (kDebugMode) {
      WidgetsBinding.instance!.addPostFrameCallback((_) => _openDebugTarget());
    }
  }

  Future<void> _expired() async {
    if (_leaving || !mounted) return;
    _leaving = true;
    debugPrint('[DocenteHome] session expired, back to SPID/CIE login');
    final message = docenteText(context, 'docente_session_expired');
    await _store.clear();
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => DocenteLoginPage(message: message)),
      (route) => false,
    );
  }

  Future<void> _leave() async {
    _leaving = true;
    await _store.clear();
    await WebViewCookies.clear();
    await RegistryProviderPreferences(sl()).clear();
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RegistryProviderPage()),
      (route) => false,
    );
  }

  void _openTab(DocenteTab tab, {int classesChip = -1}) {
    setState(() => _tab = tab);
    if (tab == DocenteTab.classes && classesChip >= 0) {
      _classesTabKey.currentState?.selectChip(classesChip);
    }
  }

  /// Debug builds: `am start --es docente_debug_web <value>` opens a screen
  /// without touching the phone. `tab:<name>`, `link:<page>[@<subject>]`
  /// (class page of the first class), `screen:<section>` (e.g. timetable)
  /// or a web path.
  Future<void> _openDebugTarget() async {
    final value = await WebViewCookies.debugWebPath();
    if (value == null || !mounted) return;
    debugPrint('[DocenteHome] debug open $value');
    if (value.startsWith('tab:')) {
      final tab =
          DocenteTab.values.where((t) => describeEnum(t) == value.substring(4));
      if (tab.isNotEmpty) _openTab(tab.first);
    } else if (value.startsWith('link:')) {
      final spec = value.substring(5).split('@');
      final subjectIndex = spec.length > 1 ? int.tryParse(spec[1]) ?? 0 : 0;
      final classes =
          parseDocenteClasses(await _api!.getPage(docenteMyClassesPath));
      final first = classes.isEmpty ? null : classes.first;
      final link = first?.linkTo(spec.first) ??
          (first == null || first.subjects.length <= subjectIndex
              ? null
              : first.subjects[subjectIndex].linkTo(spec.first));
      final screen = docenteLinkScreens[spec.first];
      if (link == null || screen == null || !mounted) return;
      // Pushed from a context below the scope, as the tabs do.
      await DocenteScope.push(
          _scaffoldKey.currentContext!, screen(link, spec.first));
    } else if (value.startsWith('screen:')) {
      final key = 'docente_section_${value.substring(7)}';
      final section = docenteSections.where((s) => s.key == key);
      if (section.isEmpty) return;
      final screen =
          docenteSectionScreen(_scaffoldKey.currentContext!, section.first);
      if (screen == null) return;
      await DocenteScope.push(_scaffoldKey.currentContext!, screen);
    } else if (value.startsWith('/')) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => DocenteWebPage(
          title: value,
          path: value,
          userAgent: _session!.userAgent,
          onSessionExpired: _expired,
        ),
      ));
    }
  }

  void _refreshTab(DocenteTab tab) {
    final key = {
      DocenteTab.home: docenteHomeRefresherKey,
      DocenteTab.classes: docenteClassesRefresherKey,
      DocenteTab.agenda: docenteAgendaRefresherKey,
      DocenteTab.noticeboard: docenteNoticeboardRefresherKey,
    }[tab];
    key?.currentState?.show();
  }

  @override
  Widget build(BuildContext context) {
    final api = _api;
    if (api == null) return const Scaffold(body: SizedBox.shrink());
    final trans = AppLocalizations.of(context)!;
    const icons = {
      DocenteTab.home: Icons.home,
      DocenteTab.classes: Icons.class_,
      DocenteTab.agenda: Icons.today,
      DocenteTab.noticeboard: Icons.email,
      DocenteTab.more: Icons.more_horiz,
    };
    final labels = {
      DocenteTab.home: trans.translate('home'),
      DocenteTab.classes: docenteText(context, 'docente_classes'),
      DocenteTab.agenda: trans.translate('agenda'),
      DocenteTab.noticeboard: trans.translate('notice_board'),
      DocenteTab.more: trans.translate('more_page'),
    };
    // Back on a tab other than home goes to home; on home it leaves the app.
    return WillPopScope(
      onWillPop: () async {
        if (_tab == DocenteTab.home) return true;
        setState(() => _tab = DocenteTab.home);
        return false;
      },
      child: DocenteScope(
        api: api,
        userAgent: _session!.userAgent,
        onSessionExpired: _expired,
        openTab: _openTab,
        logout: _leave,
        changeRegistry: _leave,
        child: Scaffold(
          key: _scaffoldKey,
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Theme.of(context).cardTheme.color,
            type: BottomNavigationBarType.fixed,
            currentIndex: _tab.index,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: (index) {
              final tab = DocenteTab.values[index];
              if (tab == _tab) _refreshTab(tab);
              setState(() => _tab = tab);
            },
            items: [
              for (final tab in DocenteTab.values)
                BottomNavigationBarItem(
                    label: labels[tab], icon: Icon(icons[tab])),
            ],
          ),
          body: IndexedStack(
            index: _tab.index,
            children: [
              const DocenteDashboardPage(),
              DocenteClassesTab(key: _classesTabKey),
              const DocenteAgendaTab(),
              const DocenteNoticeboardTab(),
              const DocenteMorePage(),
            ],
          ),
        ),
      ),
    );
  }
}
