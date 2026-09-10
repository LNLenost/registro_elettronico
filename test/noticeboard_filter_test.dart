import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/noticeboard/domain/model/notice_domain_model.dart';
import 'package:registro_elettronico/feature/noticeboard/presentation/noticeboard_page.dart';

void main() {
  test('filterNotices returns only unread notices when requested', () {
    final notices = <NoticeDomainModel>[
      NoticeDomainModel(id: 1, readStatus: false),
      NoticeDomainModel(id: 2, readStatus: true),
      NoticeDomainModel(id: 3, readStatus: null),
    ];

    expect(
      filterNotices(notices, unreadOnly: true).map((notice) => notice.id),
      [1, 3],
    );
    expect(filterNotices(notices, unreadOnly: false), same(notices));
  });

  test('filterNotices returns only notices in the selected category', () {
    final notices = <NoticeDomainModel>[
      NoticeDomainModel(id: 1, contentCategory: 'School'),
      NoticeDomainModel(id: 2, contentCategory: 'Transport'),
      NoticeDomainModel(id: 3, contentCategory: null),
    ];

    expect(
      filterNotices(notices, unreadOnly: false, category: 'School')
          .map((notice) => notice.id),
      [1],
    );
  });

  test('filterNotices filters active and expired notices', () {
    final notices = <NoticeDomainModel>[
      NoticeDomainModel(id: 1, validInRange: true),
      NoticeDomainModel(id: 2, validInRange: false),
      NoticeDomainModel(id: 3, validInRange: null),
    ];

    expect(
      filterNotices(notices, unreadOnly: false, range: 'active')
          .map((notice) => notice.id),
      [1],
    );
    expect(
      filterNotices(notices, unreadOnly: false, range: 'expired')
          .map((notice) => notice.id),
      [2, 3],
    );
  });
}
