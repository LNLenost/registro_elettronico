import 'package:flutter/material.dart';
import 'package:registro_elettronico/core/presentation/widgets/cusotm_placeholder.dart';
import 'package:registro_elettronico/feature/docente/data/docente_classes_parser.dart';
import 'package:registro_elettronico/feature/docente/data/docente_notes_parser.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_experimental.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';
import 'package:registro_elettronico/utils/date_utils.dart';

/// Notes of a class (EXPERIMENTAL, inferred parser), as the student notes
/// page: one tile per note with the kind and date. The note text is only in
/// the web page's note dialog, which is not opened.
class DocenteNotesPage extends StatefulWidget {
  final DocenteLink link;
  final String title;

  const DocenteNotesPage({Key? key, required this.link, required this.title})
      : super(key: key);

  @override
  _DocenteNotesPageState createState() => _DocenteNotesPageState();
}

class _DocenteNotesPageState extends State<DocenteNotesPage> {
  Future<DocenteNotesGrid>? _data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data ??= _fetch();
  }

  Future<DocenteNotesGrid> _fetch() {
    final scope = DocenteScope.of(context);
    return scope.guard(
        scope.api.getPage(widget.link.path).then(parseDocenteNotes).then((g) {
      debugPrint(
          '[DocenteNotes] students=${g.students} dates=${g.dates.length} '
          'notes=${g.notes.length}');
      return g;
    }));
  }

  Future<void> _refresh() async {
    final future = _fetch();
    setState(() => _data = future);
    await future.catchError(
        (_) => const DocenteNotesGrid(students: 0, dates: [], notes: []));
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: DocenteAsyncView<DocenteNotesGrid>(
        future: _data,
        isEmpty: (_) => false,
        emptyText: '',
        onRefresh: _refresh,
        builder: (grid) => ListView(
          children: [
            DocenteExperimentalBanner(
                title: widget.title, path: widget.link.path),
            if (grid.notes.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: CustomPlaceHolder(
                  icon: Icons.info,
                  text: docenteText(context, 'docente_notes_empty'),
                  showUpdate: false,
                ),
              )
            else
              for (final note in grid.notes)
                ListTile(
                  title: Text(note.student),
                  subtitle: Text([
                    docenteText(
                        context,
                        note.kind == DocenteNoteKind.disciplinary
                            ? 'docente_note_disciplinary'
                            : 'docente_note_annotation'),
                    if (note.day != null)
                      SRDateUtils.convertDateLocale(note.day, locale)
                    else
                      note.date,
                    if (note.text.isNotEmpty) note.text,
                  ].join(' - ')),
                ),
          ],
        ),
      ),
    );
  }
}
