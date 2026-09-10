import 'package:shared_preferences/shared_preferences.dart';

import 'package:registro_elettronico/utils/constants/preferences_constants.dart';

class NotificationPreferences {
  static const grades = 'grades';
  static const notices = 'notices';
  static const notes = 'notes';
  static const absences = 'absences';

  static const categories = <String>[grades, notices, notes, absences];

  static String? categoryFromMessage(Map<String, dynamic> data) {
    final category = data['category'];
    return category is String && categories.contains(category) ? category : null;
  }

  static bool isEnabled(SharedPreferences prefs, String category) {
    switch (category) {
      case grades:
        return prefs.getBool(PrefsConstants.gradesNotifications) ?? true;
      case notices:
        return prefs.getBool(PrefsConstants.noticesNotifications) ?? true;
      case notes:
        return prefs.getBool(PrefsConstants.notesNotifications) ?? true;
      case absences:
        return prefs.getBool(PrefsConstants.absencesNotifications) ?? true;
    }
    return false;
  }
}
