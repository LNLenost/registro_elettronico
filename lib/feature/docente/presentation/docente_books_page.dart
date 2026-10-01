import 'package:flutter/material.dart';
import 'package:registro_elettronico/core/presentation/widgets/cusotm_placeholder.dart';
import 'package:registro_elettronico/feature/docente/data/docente_books_parser.dart';
import 'package:registro_elettronico/feature/docente/data/docente_classes_parser.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_experimental.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';

class _BooksPage {
  final List<DocenteLink> classes;
  final List<DocenteBook> books;

  const _BooksPage(this.classes, this.books);
}

/// Textbook adoptions (EXPERIMENTAL, inferred parsers): the classes of the
/// adoptions list as the student more page tiles, and for a class its books
/// grouped by subject, as cards. A page that already lists books shows them
/// directly.
class DocenteBooksPage extends StatefulWidget {
  final String path;
  final String title;

  const DocenteBooksPage({Key? key, required this.path, required this.title})
      : super(key: key);

  @override
  _DocenteBooksPageState createState() => _DocenteBooksPageState();
}

class _DocenteBooksPageState extends State<DocenteBooksPage> {
  Future<_BooksPage>? _data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data ??= _fetch();
  }

  Future<_BooksPage> _fetch() {
    final scope = DocenteScope.of(context);
    return scope.guard(scope.api.getPage(widget.path).then((page) {
      final data = _BooksPage(
          parseDocenteBookClasses(page, base: Uri.parse(widget.path).path),
          parseDocenteBooks(page));
      debugPrint('[DocenteBooks] classes=${data.classes.length} '
          'books=${data.books.length}');
      return data;
    }));
  }

  Future<void> _refresh() async {
    final future = _fetch();
    setState(() => _data = future);
    await future.catchError((_) => const _BooksPage([], []));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: DocenteAsyncView<_BooksPage>(
        future: _data,
        isEmpty: (_) => false,
        emptyText: '',
        onRefresh: _refresh,
        builder: (data) => ListView(
          children: [
            DocenteExperimentalBanner(title: widget.title, path: widget.path),
            if (data.books.isNotEmpty)
              _BookList(books: data.books)
            else if (data.classes.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: CustomPlaceHolder(
                  icon: Icons.menu_book,
                  text: docenteText(context, 'docente_books_empty'),
                  showUpdate: false,
                ),
              )
            else
              for (final link in data.classes)
                ListTile(
                  leading: const Icon(Icons.class_),
                  title: Text(link.label),
                  onTap: () => DocenteScope.push(context,
                      DocenteBooksPage(path: link.path, title: link.label)),
                ),
          ],
        ),
      ),
    );
  }
}

class _BookList extends StatelessWidget {
  final List<DocenteBook> books;

  const _BookList({required this.books});

  @override
  Widget build(BuildContext context) {
    final bySubject = <String, List<DocenteBook>>{};
    for (final book in books) {
      bySubject.putIfAbsent(book.subject, () => []).add(book);
    }
    return Padding(
      padding: docenteListPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in bySubject.entries) ...[
            if (entry.key.isNotEmpty) DocenteHeader(entry.key),
            for (final book in entry.value)
              DocenteCard(
                leading: const Icon(Icons.menu_book),
                title: book.title,
                details: [
                  [book.author, book.publisher]
                      .where((s) => s.isNotEmpty)
                      .join(' · '),
                  ['ISBN ${book.isbn}', if (book.price.isNotEmpty) book.price]
                      .join(' · '),
                  book.flags.join(' · '),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
