import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:registro_elettronico/core/infrastructure/app_injection.dart';
import 'package:registro_elettronico/feature/core_container.dart';
import 'package:registro_elettronico/utils/constants/preferences_constants.dart';
import 'package:registro_elettronico/utils/update_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const _backgroundSyncTask = 'notification-content-sync';
const _backgroundSyncUniqueName = 'notification-content-sync-periodic';

@pragma('vm:entry-point')
void backgroundSyncDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await CoreContainer.init();
    return sl<SRUpdateManager>().syncNotificationContent();
  });
}

class BackgroundSync {
  static const defaultIntervalMinutes = 15;
  static const availableIntervals = <int>[15, 30, 60, 120];

  static int normalizeInterval(int? minutes) {
    if (minutes == null || minutes < defaultIntervalMinutes) {
      return defaultIntervalMinutes;
    }
    return minutes;
  }

  static Future<void> initialize() async {
    if (!Platform.isAndroid) return;
    await Workmanager().initialize(
      backgroundSyncDispatcher,
      isInDebugMode: kDebugMode,
    );
  }

  static Future<void> schedule([int? minutes]) async {
    if (!Platform.isAndroid) return;
    final preferences = await SharedPreferences.getInstance();
    final interval = normalizeInterval(
      minutes ?? preferences.getInt(PrefsConstants.backgroundSyncMinutes),
    );
    await preferences.setInt(PrefsConstants.backgroundSyncMinutes, interval);
    await Workmanager().cancelByUniqueName(_backgroundSyncUniqueName);
    await Workmanager().registerPeriodicTask(
      _backgroundSyncUniqueName,
      _backgroundSyncTask,
      frequency: Duration(minutes: interval),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
}
