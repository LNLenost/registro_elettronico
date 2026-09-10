import 'package:registro_elettronico/core/data/local/moor_database.dart';
import 'package:registro_elettronico/core/infrastructure/notification/local_notification.dart';
import 'package:registro_elettronico/core/infrastructure/notification/notification_diff.dart';
import 'package:registro_elettronico/utils/constants/preferences_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalContentNotificationService {
  final SRDatabase database;
  final SharedPreferences preferences;
  final LocalNotification notifications;

  LocalContentNotificationService({
    required this.database,
    required this.preferences,
    required this.notifications,
  });

  Future<void> notifyNewContent() async {
    await _notifyGrades();
    await _notifyNotices();
    await _notifyNotes();
    await _notifyAbsences();
    await _notifyReports();
  }

  Future<void> _notifyGrades() async {
    final items = await database.gradesLocalDatasource.getGrades();
    await _notifyIds(
      'grades',
      items.map((item) => item.evtId),
      'Nuovo voto',
    );
  }

  Future<void> _notifyNotices() async {
    final items = await database.noticeboardLocalDatasource.getAllNotices();
    await _notifyIds(
      'notices',
      items.map((item) => item.pubId),
      'Nuova circolare',
    );
  }

  Future<void> _notifyNotes() async {
    final items = await database.noteDao.getAllNotes();
    await _notifyIds(
      'notes',
      items.map((item) => item.id),
      'Nuova nota',
    );
  }

  Future<void> _notifyAbsences() async {
    final items = await database.absenceDao.getAllAbsences();
    await _notifyIds(
      'absences',
      items.map((item) => item.evtId),
      'Nuova assenza',
    );
  }

  Future<void> _notifyReports() async {
    final reports = await database.documentsDao.getAllSchoolReports();
    await _notifyIds(
      'reports',
      reports.map((item) => item.viewLink),
      'Nuova pagella',
    );
  }

  Future<void> _notifyIds(
    String category,
    Iterable<Object?> ids,
    String title,
  ) async {
    final current = ids.whereType<Object>().map((id) => id.toString()).toSet();
    final key = 'notificationBaseline_$category';
    final previous = preferences.getStringList(key);
    await preferences.setStringList(key, current.toList());
    if (previous == null || !_enabled(category)) return;

    final newIds = NotificationDiff.newItems<String, String>(
      previous,
      current,
      (id) => id,
    );
    for (final id in newIds) {
      await notifications.showNotificationWithDefaultSound(
        id.hashCode,
        title,
        'Nuovo contenuto disponibile',
      );
    }
  }

  bool _enabled(String category) {
    switch (category) {
      case 'grades':
        return preferences.getBool(PrefsConstants.gradesNotifications) ?? true;
      case 'notices':
        return preferences.getBool(PrefsConstants.noticesNotifications) ?? true;
      case 'notes':
        return preferences.getBool(PrefsConstants.notesNotifications) ?? true;
      case 'absences':
        return preferences.getBool(PrefsConstants.absencesNotifications) ?? true;
      case 'reports':
        return true;
    }
    return false;
  }
}
