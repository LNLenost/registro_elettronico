import 'package:flutter/material.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_web_page.dart';

const docenteExperimentalColor = Colors.orange;

/// Subtitle of the tiles that open an experimental screen.
class DocenteExperimentalLabel extends StatelessWidget {
  const DocenteExperimentalLabel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Text(
        docenteText(context, 'docente_experimental'),
        style: const TextStyle(color: docenteExperimentalColor),
      );
}

/// Shown on top of the screens inferred from the structure of web pages that
/// had no data on the mapped account: says the screen is not verified and
/// opens the web page it reads, to compare.
class DocenteExperimentalBanner extends StatelessWidget {
  final String title;
  final String path;

  const DocenteExperimentalBanner(
      {Key? key, required this.title, required this.path})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scope = DocenteScope.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: docenteExperimentalColor),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.science, color: docenteExperimentalColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  docenteText(context, 'docente_experimental'),
                  style: const TextStyle(
                      color: docenteExperimentalColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Text(docenteText(context, 'docente_experimental_message'),
                style: const TextStyle(fontSize: 12)),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => DocenteScope.push(
                  context,
                  DocenteWebPage(
                    title: title,
                    path: path,
                    userAgent: scope.userAgent,
                    onSessionExpired: scope.onSessionExpired,
                  ),
                ),
                child: Text(docenteText(context, 'docente_open_web')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
