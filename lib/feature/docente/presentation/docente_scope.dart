import 'package:flutter/material.dart';
import 'package:registro_elettronico/feature/docente/data/docente_web_api.dart';

/// Tabs of the teacher area, in the positions of the student bottom bar
/// (home, grades -> classes, agenda, noticeboard, more).
enum DocenteTab { home, classes, agenda, noticeboard, more }

/// What every teacher screen needs: the web client, how to react to an
/// expired session, and the navigation actions of the bottom bar.
class DocenteScope extends InheritedWidget {
  final DocenteWebApi api;
  final String userAgent;
  final VoidCallback onSessionExpired;
  final void Function(DocenteTab tab, {int classesChip}) openTab;
  final VoidCallback logout;
  final VoidCallback changeRegistry;

  const DocenteScope({
    Key? key,
    required this.api,
    required this.userAgent,
    required this.onSessionExpired,
    required this.openTab,
    required this.logout,
    required this.changeRegistry,
    required Widget child,
  }) : super(key: key, child: child);

  static DocenteScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DocenteScope>()!;

  /// Runs [future]; on an expired session goes back to the SPID/CIE login.
  Future<T> guard<T>(Future<T> future) => future.catchError((Object e) {
        if (e is DocenteSessionExpired) onSessionExpired();
        throw e;
      });

  /// Pushes [page] keeping this scope available to it (routes are built
  /// above the teacher navigator).
  static Future<T?> push<T>(BuildContext context, Widget page) {
    final scope = of(context);
    return Navigator.of(context).push<T>(MaterialPageRoute(
      builder: (_) => DocenteScope(
        api: scope.api,
        userAgent: scope.userAgent,
        onSessionExpired: scope.onSessionExpired,
        openTab: scope.openTab,
        logout: scope.logout,
        changeRegistry: scope.changeRegistry,
        child: page,
      ),
    ));
  }

  @override
  bool updateShouldNotify(DocenteScope oldWidget) => api != oldWidget.api;
}
