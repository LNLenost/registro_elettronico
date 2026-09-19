import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/noticeboard/data/model/notice/notice_remote_model.dart';
import 'package:registro_elettronico/feature/noticeboard/data/repository/noticeboard_repository_impl.dart';

void main() {
  test('keeps a locally read notice read after refresh', () {
    expect(preserveReadStatus(false, true), isTrue);
    expect(preserveReadStatus(true, false), isTrue);
    expect(preserveReadStatus(false, false), isFalse);
  test('reads the ClasseViva response flag when REST readStatus is absent', () {
    expect(noticeReadStatus({'response': {'letto': 1}}), isTrue);
    expect(noticeReadStatus({'response': {'letto': 0}}), isFalse);
    expect(
      noticeReadStatus({
        'readStatus': false,
        'response': {'letto': 1},
      }),
      isFalse,
    );
  });
}
