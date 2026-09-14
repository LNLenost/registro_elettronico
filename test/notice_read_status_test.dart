import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/noticeboard/data/repository/noticeboard_repository_impl.dart';

void main() {
  test('keeps a locally read notice read after refresh', () {
    expect(preserveReadStatus(false, true), isTrue);
    expect(preserveReadStatus(true, false), isTrue);
    expect(preserveReadStatus(false, false), isFalse);
  });
}
