import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/core/infrastructure/notification/notification_diff.dart';

void main() {
  test('returns only records not present before synchronization', () {
    final result = NotificationDiff.newItems<int, int>(
      const [1, 2],
      const [2, 3, 4],
      (item) => item,
    );

    expect(result, equals(const [3, 4]));
  });
}
