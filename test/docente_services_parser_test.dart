import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/docente/data/docente_services_parser.dart';

void main() {
  test('forms grouped by section headers', () {
    const page = '''
<div class="underline"><h3>COMUNI PER ATA/DOCENTI</h3></div>
<div class="rigo_selezione_modifica titolo_modulo" abilitato="SI"><table><tr>
  <td class="apri_modulo" codice="125"><span>Mod: 125</span><br>
  <span class="font_size_15" codice_modulo="125">Domanda ricostruzione carriera</span></td></tr></table></div>
<div class="underline"><h3>DOCENTI</h3></div>
<div class="rigo_selezione_modifica titolo_modulo"><table><tr>
  <td><span>Mod: 130_1</span><span codice_modulo="130_1">Comunicazione sciopero</span></td></tr></table></div>
''';
    final forms = parseDocenteForms(page);
    expect(forms.map((f) => f.code), ['125', '130_1']);
    expect(forms.first.section, 'COMUNI PER ATA/DOCENTI');
    expect(forms.last.section, 'DOCENTI');
    expect(forms.first.title, 'Domanda ricostruzione carriera');
  });

  test('requests owner from the page and requests from the JSON', () {
    expect(
        parseDocenteRequestsOwner(
            'var x = {"id_anagrafe":{"id":"12345678","cognome":"X"}};'),
        '12345678');
    expect(parseDocenteRequestsOwner('nothing'), isNull);
    final requests = parseDocenteRequests({
      'error': '',
      'result': 1,
      'data': [
        {
          'id': 7,
          'descrizione': 'Permesso breve',
          'stato_richiesta': 'Autorizzata',
          'data_richiesta': '2026-09-01'
        }
      ]
    });
    expect(requests.single.title, 'Permesso breve');
    expect(requests.single.status, 'Autorizzata');
    expect(parseDocenteRequests({'data': []}), isEmpty);
  });

  test('Ver.Di meetings: filters and rows after the header', () {
    const page = '''
<select class="filtro_tipo_evento"><option value="">Tipologia</option>
  <option value="2">Consiglio di classe</option></select>
<table>
<tr class="griglia open_sans_semibold"><td></td><td>Evento</td><td>Data</td><td>Luogo</td></tr>
<tr><td></td><td>Consiglio 3TELB</td><td>05-10-2026</td><td>Aula 2</td></tr>
</table>
''';
    final data = parseDocenteVerdiMeetings(page);
    expect(data.types, {'2': 'Consiglio di classe'});
    expect(data.meetings.single.title, 'Consiglio 3TELB');
    expect(data.meetings.single.place, 'Aula 2');
  });

  test('signature book empty state', () {
    final book = parseDocenteSignBook(
        '<select><option>Visto</option></select><p>NESSUN DOCUMENTO DA FIRMARE</p>');
    expect(book.filters, ['Visto']);
    expect(book.documents, isEmpty);
  });

  test('Eligo error state', () {
    final state = parseDocenteEligo('''
<div class="error-container"><h2>Autenticazione fallita</h2>
<p class="error-line">Errore in Eligo: 203 - Utente non ancora creato</p></div>''');
    expect(state.available, isFalse);
    expect(state.title, 'Autenticazione fallita');
    expect(state.message, contains('203'));
  });

  test('PLS classes and students', () {
    final classes = parseDocentePlsClasses(
        '<a href="lista_studenti_pfi.php?classe_id=10&amp;stampa=0">4ELEA elettronica</a>');
    expect(classes.single.path,
        '/pdp/app/default/lista_studenti_pfi.php?classe_id=10&stampa=0');
    final data = parseDocentePlsStudents('''
<span class="page_title_fixed">Programmazione</span><span class="page_title_variable">4ELEA</span>
<table><tr class="row_stud" studente_id="11"><td><p>Rossi Anna</p><p>01-01-2010</p></td></tr></table>''');
    expect(data.title, 'Programmazione 4ELEA');
    expect(data.students.single.name, 'Rossi Anna');
    expect(data.students.single.birth, '01-01-2010');
  });
}
