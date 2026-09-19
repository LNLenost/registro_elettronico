import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/core/infrastructure/notification/local_notification.dart';
import 'package:timezone/timezone.dart';

void main() {
  test('converts agenda reminder time to a timezone-aware time', () {
    final scheduled = LocalNotification.timezoneTime(
      DateTime(2026, 9, 19, 8, 30),
    );

    expect(scheduled, isA<TZDateTime>());
    expect(scheduled.year, 2026);
    expect(scheduled.month, 9);
    expect(scheduled.day, 19);
    expect(scheduled.hour, 8);
    expect(scheduled.minute, 30);
  });
}
