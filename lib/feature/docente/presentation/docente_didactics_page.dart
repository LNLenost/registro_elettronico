import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/core/presentation/widgets/cusotm_placeholder.dart';
import 'package:registro_elettronico/feature/docente/data/docente_didactics_parser.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_experimental.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';

/// The teacher's didactic materials (EXPERIMENTAL, inferred parser), as the
/// student didactics page: expandable folders with their contents. Read
/// only: contents are listed, not downloaded, uploaded or deleted.
class DocenteDidacticsPage extends StatefulWidget {
  final String path;
  final String title;

  const DocenteDidacticsPage(
      {Key? key, required this.path, required this.title})
      : super(key: key);

  @override
  _DocenteDidacticsPageState createState() => _DocenteDidacticsPageState();
}

class _DocenteDidacticsPageState extends State<DocenteDidacticsPage> {
  Future<List<DocenteFolder>>? _data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data ??= _fetch();
  }

  Future<List<DocenteFolder>> _fetch() {
    final scope = DocenteScope.of(context);
    return scope.guard(
        scope.api.getPage(widget.path).then(parseDocenteDidactics).then((f) {
      debugPrint('[DocenteDidactics] folders=${f.length} '
          'contents=${f.fold<int>(0, (n, f) => n + f.materials.length)}');
      return f;
    }));
  }

  Future<void> _refresh() async {
    final future = _fetch();
    setState(() => _data = future);
    await future.catchError((_) => <DocenteFolder>[]);
  }

  @override
  Widget build(BuildContext context) {
    final noName = AppLocalizations.of(context)!.translate('no_name')!;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: DocenteAsyncView<List<DocenteFolder>>(
        future: _data,
        isEmpty: (_) => false,
        emptyText: '',
        onRefresh: _refresh,
        builder: (folders) => ListView(
          children: [
            DocenteExperimentalBanner(title: widget.title, path: widget.path),
            if (folders.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: CustomPlaceHolder(
                  icon: Icons.folder,
                  text: docenteText(context, 'docente_didactics_empty'),
                  showUpdate: false,
                ),
              ),
            for (final folder in folders)
              ExpandableTheme(
                data: ExpandableThemeData(
                    iconColor: Theme.of(context).iconTheme.color),
                child: ExpandablePanel(
                  collapsed: Container(),
                  theme: const ExpandableThemeData(
                      tapHeaderToExpand: true, hasIcon: true),
                  header: ListTile(
                    leading: const Icon(Icons.folder),
                    title: Text(folder.name.isNotEmpty ? folder.name : noName),
                    subtitle: Text('${folder.materials.length}'),
                  ),
                  expanded: Column(children: [
                    for (final material in folder.materials)
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 32.0),
                        leading: Icon(_icon(material.kind)),
                        title: Text(
                            material.name.isNotEmpty ? material.name : noName),
                        subtitle:
                            material.date.isEmpty ? null : Text(material.date),
                      ),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Icons of the student contents list (teacher_card.dart).
  IconData _icon(DocenteMaterialKind kind) {
    switch (kind) {
      case DocenteMaterialKind.link:
        return Icons.link;
      case DocenteMaterialKind.text:
        return Icons.text_fields;
      case DocenteMaterialKind.file:
        return Icons.cloud_download;
    }
  }
}
