import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:intl/intl.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/core/presentation/custom/states/sr_loading_view.dart';
import 'package:registro_elettronico/core/presentation/custom/states/sr_search_empty_view.dart';
import 'package:registro_elettronico/core/presentation/widgets/cusotm_placeholder.dart';
import 'package:registro_elettronico/feature/docente/data/docente_web_api.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_async_view.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_navigator_page.dart';
import 'package:registro_elettronico/feature/docente/presentation/docente_scope.dart';

/// Teacher noticeboard, as the student one (noticeboard_page.dart): search
/// bar, read and validity filters, category dropdown and notice cards.
class DocenteNoticeboardTab extends StatefulWidget {
  const DocenteNoticeboardTab({Key? key}) : super(key: key);

  @override
  _DocenteNoticeboardTabState createState() => _DocenteNoticeboardTabState();
}

class _DocenteNoticeboardTabState extends State<DocenteNoticeboardTab> {
  late SearchBar _searchBar;
  String _query = '';
  bool _unreadOnly = false;
  String _range = 'all';
  String? _category;
  Future<DocenteNotices>? _notices;

  @override
  void initState() {
    super.initState();
    _searchBar = SearchBar(
      setState: setState,
      onChanged: (query) => setState(() => _query = query),
      buildDefaultAppBar: _buildAppBar,
      onClosed: () => setState(() => _query = ''),
      onCleared: () => setState(() => _query = ''),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notices ??= _fetch();
  }

  Future<DocenteNotices> _fetch() {
    final scope = DocenteScope.of(context);
    return scope.guard(scope.api.getNotices());
  }

  Future<void> _refresh() async {
    final future = _fetch();
    setState(() => _notices = future);
    await future.catchError((_) => const DocenteNotices(unread: [], read: []));
  }

  AppBar _buildAppBar(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    return AppBar(
      title: Text(trans.translate('notice_board')!),
      actions: [
        _searchBar.getSearchAction(context),
        PopupMenuButton<bool>(
          initialValue: _unreadOnly,
          icon: const Icon(Icons.filter_list),
          onSelected: (value) => setState(() => _unreadOnly = value),
          itemBuilder: (context) => [
            PopupMenuItem(
                value: false, child: Text(trans.translate('all_notices')!)),
            PopupMenuItem(
                value: true, child: Text(trans.translate('unread_notices')!)),
          ],
        ),
        PopupMenuButton<String>(
          initialValue: _range,
          icon: const Icon(Icons.event_available),
          onSelected: (value) => setState(() => _range = value),
          itemBuilder: (context) => [
            PopupMenuItem(
                value: 'all', child: Text(trans.translate('all_notices')!)),
            PopupMenuItem(
                value: 'active',
                child: Text(trans.translate('active_notices')!)),
            PopupMenuItem(
                value: 'expired',
                child: Text(trans.translate('expired_notices')!)),
          ],
        ),
      ],
    );
  }

  List<DocenteNotice> _filter(List<DocenteNotice> notices) {
    final now = DateTime.now();
    final query = _query.toLowerCase();
    return notices.where((n) {
      if (_unreadOnly && n.read) return false;
      if (_category != null && n.category != _category) return false;
      final active = n.expiresOn == null ||
          !n.expiresOn!.isBefore(DateUtils.dateOnly(now));
      if (_range == 'active' && !active) return false;
      if (_range == 'expired' && active) return false;
      if (query.length > 1 &&
          !'${n.title} ${n.category}'.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: _searchBar.build(context),
      body: RefreshIndicator(
        key: docenteNoticeboardRefresherKey,
        onRefresh: _refresh,
        child: FutureBuilder<DocenteNotices>(
          future: _notices,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return CustomPlaceHolder(
                icon: Icons.error_outline,
                text: docenteText(context, 'docente_error'),
                showUpdate: true,
                onTap: _refresh,
              );
            }
            if (!snapshot.hasData) return const SRLoadingView();
            final all = [...snapshot.data!.unread, ...snapshot.data!.read];
            if (all.isEmpty) {
              return CustomPlaceHolder(
                icon: Icons.email,
                text: trans.translate('no_notices'),
                showUpdate: true,
                onTap: () =>
                    docenteNoticeboardRefresherKey.currentState?.show(),
              );
            }
            final categories = all
                .map((n) => n.category)
                .where((c) => c.isNotEmpty)
                .toSet()
                .toList()
              ..sort();
            final notices = _filter(all);
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notices.isEmpty ? 2 : notices.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Row(children: [
                    Text(trans.translate('category')!),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String?>(
                        isExpanded: true,
                        value: _category,
                        items: [
                          DropdownMenuItem(
                              value: null,
                              child: Text(trans.translate('all_notices')!)),
                          for (final c in categories)
                            DropdownMenuItem(value: c, child: Text(c)),
                        ],
                        onChanged: (value) => setState(() => _category = value),
                      ),
                    ),
                  ]);
                }
                if (notices.isEmpty) {
                  return const SizedBox(
                      height: 300, child: SrSearchEmptyView());
                }
                return _NoticeCard(notice: notices[i - 1]);
              },
            );
          },
        ),
      ),
    );
  }
}

/// As the student NoticeCard. Shows the text already in the list response:
/// opening the circular on the server would record the read receipt.
class _NoticeCard extends StatelessWidget {
  final DocenteNotice notice;

  const _NoticeCard({required this.notice});

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ListTile(
          title: Text(notice.title),
          subtitle: Text(notice.publishedOn == null
              ? notice.category
              : DateFormat.yMMMMd(trans.locale.toString())
                  .format(notice.publishedOn!)),
          trailing:
              Icon(Icons.mail, color: notice.read ? Colors.green : Colors.red),
          onTap: () => showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(notice.title),
              content: SingleChildScrollView(
                child: Text(notice.text.isEmpty
                    ? docenteText(context, 'docente_notice_no_text')
                    : notice.text),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(trans.translate('ok')!)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
