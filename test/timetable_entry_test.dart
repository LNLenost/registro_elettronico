import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/timetable/domain/model/timetable_entry_domain_model.dart';

void main() {
  test('stores and renders a manual weekly timetable range', () {
    final entry = TimetableEntryDomainModel.manual(
      id: null,
      dayOfWeek: 0,
      subjectName: 'Italiano',
      startMinutes: 8 * 60 + 30,
      endMinutes: 10 * 60,
    );

    expect(entry.dayOfWeek, 0);
    expect(entry.subjectName, 'Italiano');
    expect(entry.startMinutes, 8 * 60 + 30);
    expect(entry.endMinutes, 10 * 60);
    expect(entry.hasValidTimeRange, isTrue);
  });

  test('rejects a manual weekly timetable range without an end after start', () {
    final entry = TimetableEntryDomainModel.manual(
      id: null,
      dayOfWeek: 5,
      subjectName: 'Fisica',
      startMinutes: 10 * 60,
      endMinutes: 10 * 60,
    );

    expect(entry.hasValidTimeRange, isFalse);
  });
}
