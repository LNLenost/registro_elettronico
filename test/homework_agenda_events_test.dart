import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/agenda/domain/model/agenda_event_domain_model.dart';
import 'package:registro_elettronico/feature/homework/data/homework_remote_datasource.dart';

void main() {
  test('maps a homework with deadline to a full-day agenda event', () {
    final events = homeworkAgendaEvents([
      const Homework(
        id: '42',
        subject: 'Matematica',
        teacher: 'Rossi',
        instructions: 'Esercizi 1 e 2',
        period: 'Valido dal: 15/09/2026 Scadenza: 18/09/2026',
      ),
    ]);

    expect(events, hasLength(1));
    expect(events.single.begin, DateTime(2026, 9, 18));
    expect(events.single.isFullDay, isTrue);
    expect(events.single.subjectName, 'Matematica');
    expect(events.single.notes, 'Esercizi 1 e 2');
    expect(events.single.code, 'HOMEWORK:42');
    expect(events.single.isLocal, isFalse);
  });

  test('omits homework without a parseable deadline from the calendar', () {
    final events = homeworkAgendaEvents([
      const Homework(
        id: '43',
        subject: 'Italiano',
        teacher: 'Bianchi',
        instructions: 'Leggere il capitolo',
        period: 'Valido dal: 15/09/2026',
      ),
    ]);

    expect(events, isEmpty);
  });

  test('rejects an impossible homework deadline instead of normalizing it', () {
    const homework = Homework(
      id: '44',
      subject: 'Italiano',
      teacher: 'Bianchi',
      instructions: 'Leggere il capitolo',
      period: 'Scadenza: 31/02/2026',
    );

    expect(homework.deadline, isNull);
  });

  test('combines agenda events and homework for the selected calendar day', () {
    final agenda = AgendaEventDomainModel(
      begin: DateTime(2026, 9, 18, 10),
      title: 'Verifica',
    );
    final homework = homeworkAgendaEvents([
      const Homework(
        id: '42',
        subject: 'Matematica',
        teacher: 'Rossi',
        instructions: 'Esercizi 1 e 2',
        period: 'Scadenza: 18/09/2026',
      ),
      const Homework(
        id: '43',
        subject: 'Italiano',
        teacher: 'Bianchi',
        instructions: 'Leggere il capitolo',
        period: 'Scadenza: 19/09/2026',
      ),
    ]);

    final events = agendaEventsForDay(
      [agenda],
      homework,
      DateTime(2026, 9, 18),
    );

    expect(events, hasLength(2));
    expect(events.first.title, 'Verifica');
    expect(events.last.code, 'HOMEWORK:42');
  });
}
