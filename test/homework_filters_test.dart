import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/homework/data/homework_filters.dart';
import 'package:registro_elettronico/feature/homework/data/homework_remote_datasource.dart';

const _today = DateTime(2026, 9, 15);

Homework _homework(String id, String deadline) => Homework(
      id: id,
      subject: 'Materia',
      teacher: 'Docente',
      instructions: 'Istruzioni',
      period: 'Scadenza: $deadline',
    );

void main() {
  test('filters homework by deadline and completion', () {
    final homeworks = [
      _homework('due', '18/09/2026'),
      _homework('expired', '14/09/2026'),
      _homework('done', '16/09/2026'),
    ];

    expect(
      filterHomeworks(homeworks, HomeworkFilter.dueSoon, _today, const {}),
      hasLength(2),
    );
    expect(
      filterHomeworks(homeworks, HomeworkFilter.expired, _today, const {}),
      [homeworks[1]],
    );
    expect(
      filterHomeworks(homeworks, HomeworkFilter.completed, _today, {'done'}),
      [homeworks[2]],
    );
  });
}