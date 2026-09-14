import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/substitutions/data/sostituzioni_docenti_api.dart';

void main() {
  test('parses teacher-room substitution rows', () {
    const page = '''
      <table><tbody><tr>
        <td>1<br>(8.00-8.50)</td><td>2A (A1)</td><td>Docente assente</td>
        <td>Docente sostituto</td><td>-</td><td>NO</td><td>Nota</td><td></td>
      </tr></tbody></table>
    ''';

    expect(parseSubstitutionRows(page), [
      {
        'Ora': '1 (8.00-8.50)',
        'Classe': '2A (A1)',
        'Doc. Assente': 'Docente assente',
        'Sost. 1': 'Docente sostituto',
        'Sost. 2': '-',
        'Pagam.': 'NO',
        'Note': 'Nota',
      },
    ]);
  });
}
