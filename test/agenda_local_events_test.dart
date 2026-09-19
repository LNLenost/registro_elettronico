import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/core/data/local/moor_database.dart';
import 'package:registro_elettronico/feature/agenda/data/repository/agenda_repository_impl.dart';

AgendaEventLocalModel _event(int id, {bool isLocal = false}) =>
    AgendaEventLocalModel(
      evtId: id,
      evtCode: '',
      begin: DateTime(2026, 9, 19),
      end: DateTime(2026, 9, 19),
      isFullDay: false,
      notes: '',
      authorName: '',
      classDesc: '',
      subjectId: 0,
      subjectDesc: '',
      isLocal: isLocal,
      labelColor: null,
      title: '',
    );

void main() {
  test('keeps manually created agenda events during remote sync', () {
    final removed = agendaEventsMissingFromRemote(
      localEvents: [_event(1, isLocal: true), _event(2), _event(3)],
      remoteIds: {3},
    );

    expect(removed.map((event) => event.evtId), [2]);
  });
}
