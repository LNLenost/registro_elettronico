import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/core/infrastructure/notification/notification_preferences.dart';

void main() {
  test('accepts only known notification categories', () {
    expect(
      NotificationPreferences.categoryFromMessage({'category': 'grades'}),
      equals(NotificationPreferences.grades),
    );
    expect(NotificationPreferences.categoryFromMessage({}), isNull);
    expect(
      NotificationPreferences.categoryFromMessage({'category': 'unknown'}),
      isNull,
    );
  });
}
