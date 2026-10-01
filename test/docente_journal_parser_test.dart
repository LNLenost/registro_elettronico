import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/docente/data/docente_journal_parser.dart';

String _row(String date, String hour, String activity, String note) => '''
<tr class="rigtab">
  <td title="3B CORSO"> 3B CORSO </td><td title="FISICA"> FISICA </td>
  <td> $date </td><td> $hour&nbsp; </td><td> BIANCHI MARIO </td>
  <td class="update_firma" evento_id="1"><span class="attivita">$activity</span>&nbsp;:&nbsp;<span class="nota_1">$note</span>&nbsp;<span class="nota_2"></span></td>
  <td class="update_uda_cmp"> () </td>
</tr>''';

// Same structure as /cvv/app/default/gioprof.php, invented content.
final _page = '''
<table id="sort_table" class="tablesorter">
<thead><tr><th>Classe</th><th>Materia</th><th>Giorno</th><th>Ora</th><th>Docente</th><th>Argomento</th><th>UDA</th></tr></thead>
<tbody>
${_row('14/09/2026', '1^ (1)', 'Lezione', 'Presentazione del corso.')}
${_row('21/09/2026', '2^ (2)', 'Laboratorio', 'Misure con oscilloscopio.')}
</tbody>
</table>
''';

void main() {
  test('parses journal lessons, newest first', () {
    final lessons = parseDocenteJournal(_page);
    expect(lessons.map((l) => l.date), ['21/09/2026', '14/09/2026']);
    final last = lessons.first;
    expect(last.className, '3B CORSO');
    expect(last.subject, 'FISICA');
    expect(last.hour, '2^ (2)');
    expect(last.teacher, 'BIANCHI MARIO');
    expect(last.activity, 'Laboratorio');
    expect(last.topic, 'Misure con oscilloscopio.');
    expect(last.day, DateTime(2026, 9, 21));
  });
}
