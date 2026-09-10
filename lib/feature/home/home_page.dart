import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:registro_elettronico/core/infrastructure/app_injection.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/feature/home/sections/events/home_events.dart';
import 'package:registro_elettronico/feature/home/sections/grades/home_grades.dart';
import 'package:registro_elettronico/feature/home/sections/header/home_header.dart';
import 'package:registro_elettronico/feature/home/sections/lessons/home_lessons.dart';
import 'package:registro_elettronico/feature/substitutions/substitutions_page.dart';
import 'package:registro_elettronico/feature/timetable/presentation/timetable_page.dart';
import 'package:registro_elettronico/utils/update_manager.dart';

final GlobalKey<RefreshIndicatorState> homeRefresherKey = GlobalKey();

class HomePage extends StatefulWidget {
  final bool fromLogin;

  const HomePage({
    Key? key,
    this.fromLogin = false,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    if (widget.fromLogin) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.translate('updating_home_data')!,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: null,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: RefreshIndicator(
          key: homeRefresherKey,
          onRefresh: () => _updateHomeData(context),
          child: ListView(
            padding: EdgeInsets.zero,
            physics: ClampingScrollPhysics(),
            children: [
              HomeHeader(),
              _TodayActions(),
              // GRADES
              HomeGrades(),
              // LESSONS
              HomeLessonsHeader(),

              SizedBox(
                height: 140,
                child: HomeLessons(),
              ),
              HomeAgendaHeader(),
              HomeEvents(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateHomeData(BuildContext context) async {
    final SRUpdateManager srUpdateManager = sl();
    return srUpdateManager.updateHomeData(context);
  }
}

class _TodayActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _TodayAction(
              icon: Icons.access_time,
              label: AppLocalizations.of(context)!.translate('timetable')!,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => TimetablePage(),
              )),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TodayAction(
              icon: Icons.sync_problem,
              label: AppLocalizations.of(context)!
                  .translate('substitutions_title')!,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => SubstitutionsPage(),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TodayAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
