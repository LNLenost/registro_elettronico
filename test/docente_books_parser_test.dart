import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/docente/data/docente_books_parser.dart';

// Inferred: the mapped account had no classes in
// /ldt/app/default/libri_classi.php.
const _classes = '''
<table>
<tr class="page-header"><td><a href="../../../home/app/default/menu_classeviva.php?classe_id=0">Home</a></td></tr>
<tr><td><a href="libri_classe.php?classe_id=10&amp;anno_scol=2026">3TELB</a></td><td>Telecomunicazioni</td></tr>
<tr><td><a href="libri_classe.php?classe_id=11&amp;anno_scol=2026">4ELEA</a></td></tr>
</table>
''';

const _books = '''
<table>
<tr><th>Materia</th><th>Codice ISBN</th><th>Autore</th><th>Titolo</th><th>Editore</th><th>Prezzo</th><th>Da acquistare</th><th>Consigliato</th></tr>
<tr><td>Informatica</td><td>9788808123456</td><td>Rossi</td><td>Programmare in C</td><td>Zanichelli</td><td>25,00</td><td>S&igrave;</td><td>No</td></tr>
<tr><td>Sistemi</td><td>978-88-203-1234-5</td><td>Verdi</td><td>Reti</td><td>Hoepli</td><td>30,00</td><td>No</td><td>X</td></tr>
</table>
''';

void main() {
  test('classes are the content links carrying a classe_id', () {
    final classes = parseDocenteBookClasses(_classes);
    expect(classes.map((c) => c.label), ['3TELB', '4ELEA']);
    expect(classes.first.path,
        '/ldt/app/default/libri_classe.php?classe_id=10&anno_scol=2026');
  });

  test('books are the rows with an ISBN, columns named by the header', () {
    final books = parseDocenteBooks(_books);
    expect(books, hasLength(2));
    expect(books.first.isbn, '9788808123456');
    expect(books.first.title, 'Programmare in C');
    expect(books.first.subject, 'Informatica');
    expect(books.first.author, 'Rossi');
    expect(books.first.publisher, 'Zanichelli');
    expect(books.first.price, '25,00');
    expect(books.first.flags, ['Da acquistare']);
    expect(books.last.isbn, '978-88-203-1234-5');
    expect(books.last.flags, ['Consigliato']);
  });
}
