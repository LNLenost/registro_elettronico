import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/core/infrastructure/notification/background_sync.dart';

void main() {
  test('normalizes background sync to Android minimum interval', () {
    expect(BackgroundSync.normalizeInterval(null), 15);
    expect(BackgroundSync.normalizeInterval(10), 15);
    expect(BackgroundSync.normalizeInterval(30), 30);
  });
}
