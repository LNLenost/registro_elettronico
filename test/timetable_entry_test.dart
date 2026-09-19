import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/timetable/domain/model/timetable_entry_domain_model.dart';
import 'package:registro_elettronico/feature/timetable/presentation/timetable_page.dart'
    show timetableColorForSubject;

void main() {
  test('stores and renders a manual weekly timetable range', () {
    final entry = TimetableEntryDomainModel.manual(
      id: null,
      dayOfWeek: 0,
      subjectName: 'Italiano',
      startHour: 8,
      endHour: 10,
    );

    expect(entry.dayOfWeek, 0);
    expect(entry.subjectName, 'Italiano');
    expect(entry.startHour, 8);
    expect(entry.endHour, 10);
    expect(entry.hasValidTimeRange, isTrue);
  });

  test('uses a stable color for the same subject', () {
    expect(
      timetableColorForSubject('Informatica'),
      timetableColorForSubject('Informatica'),
    );
  });

  test('rejects a manual weekly timetable range without an end after start', () {
    final entry = TimetableEntryDomainModel.manual(
      id: null,
      dayOfWeek: 5,
      subjectName: 'Fisica',
      startHour: 10,
      endHour: 10,
    );

    expect(entry.hasValidTimeRange, isFalse);
  });
}
