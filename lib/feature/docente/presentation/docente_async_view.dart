import 'package:flutter/material.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/core/presentation/custom/states/sr_loading_view.dart';
import 'package:registro_elettronico/core/presentation/widgets/cusotm_placeholder.dart';
import 'package:registro_elettronico/feature/settings/widgets/header_text.dart';

/// Localized text for the teacher screens (keys `docente_*` in lang/*.json).
String docenteText(BuildContext context, String key) =>
    AppLocalizations.of(context)?.translate(key) ?? key;

/// Loading / error / empty states shared by the teacher screens, with the
/// same widgets as the student screens.
class DocenteAsyncView<T> extends StatelessWidget {
  final Future<T>? future;
  final bool Function(T) isEmpty;
  final String emptyText;
  final IconData emptyIcon;
  final Widget Function(T) builder;
  final Future<void> Function()? onRefresh;

  const DocenteAsyncView({
    Key? key,
    required this.future,
    required this.isEmpty,
    required this.emptyText,
    required this.builder,
    this.emptyIcon = Icons.inbox_outlined,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CustomPlaceHolder(
            icon: Icons.error_outline,
            text: docenteText(context, 'docente_error'),
            showUpdate: onRefresh != null,
            updateMessage: docenteText(context, 'docente_retry'),
            onTap: onRefresh,
          );
        }
        if (!snapshot.hasData) return const SRLoadingView();
        final data = snapshot.data!;
        final body = isEmpty(data)
            ? CustomPlaceHolder(
                icon: emptyIcon, text: emptyText, showUpdate: false)
            : builder(data);
        return onRefresh == null
            ? body
            : RefreshIndicator(onRefresh: onRefresh!, child: body);
      },
    );
  }
}

/// Group header, as in the student lists (accent colour).
class DocenteHeader extends StatelessWidget {
  final String text;

  const DocenteHeader(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: HeaderText(text: text),
      );
}

/// Card as in the lessons list: title 15, details 12, optional leading and
/// trailing widgets.
class DocenteCard extends StatelessWidget {
  final String title;
  final List<String> details;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Widget? child;

  const DocenteCard({
    Key? key,
    required this.title,
    this.details = const [],
    this.leading,
    this.trailing,
    this.onTap,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lines = details.where((d) => d.trim().isNotEmpty).toList();
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null)
                Padding(
                    padding: const EdgeInsets.only(right: 16), child: leading),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15)),
                    if (lines.isNotEmpty) const SizedBox(height: 8),
                    for (final line in lines)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(line,
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .textTheme
                                    .caption
                                    ?.color)),
                      ),
                    if (child != null) child!,
                  ],
                ),
              ),
              if (trailing != null)
                Padding(
                    padding: const EdgeInsets.only(left: 12), child: trailing),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round status badge (the student absence/grade cards use status colours).
class DocenteBadge extends StatelessWidget {
  final String text;
  final Color color;

  const DocenteBadge(this.text, this.color, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: 18,
        backgroundColor: color,
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      );
}

const docenteListPadding = EdgeInsets.all(12);

/// Previous / next period bar shown above a list (day, month, range).
class DocentePeriodBar extends StatelessWidget {
  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onTapLabel;

  const DocentePeriodBar({
    Key? key,
    required this.label,
    required this.onPrevious,
    required this.onNext,
    this.onTapLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
        child: Row(
          children: [
            IconButton(
                icon: const Icon(Icons.chevron_left), onPressed: onPrevious),
            Expanded(
              child: TextButton(
                onPressed: onTapLabel,
                child: Text(label, textAlign: TextAlign.center),
              ),
            ),
            IconButton(
                icon: const Icon(Icons.chevron_right), onPressed: onNext),
          ],
        ),
      );
}
