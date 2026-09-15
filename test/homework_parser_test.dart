import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/homework/data/homework_remote_datasource.dart';

void main() {
  test('parses a ClasseViva homework row', () {
    const page = '''
      <table><tr id_compito="42" class="compito_row">
        <td></td>
        <td><div>Matematica</div><div>DOCENTE</div></td>
        <td><p class="istruzioni_p">Esercizi 1<br>e 2</p></td>
        <td><div>Valido dal:</div> 15/09/2026 <div>Scadenza:</div> 18/09/2026</td>
      </tr></table>
    ''';

    final homework = parseHomeworks(page).single;

    expect(homework.id, '42');
    expect(homework.subject, 'Matematica');
    expect(homework.teacher, 'DOCENTE');
    expect(homework.instructions, 'Esercizi 1 e 2');
    expect(homework.period, contains('18/09/2026'));
  });
}