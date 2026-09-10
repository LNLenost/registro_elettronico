import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:open_file/open_file.dart';
import 'package:registro_elettronico/core/infrastructure/app_injection.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/core/presentation/custom/states/sr_failure_view.dart';
import 'package:registro_elettronico/core/presentation/custom/states/sr_loading_view.dart';
import 'package:registro_elettronico/core/presentation/custom/states/sr_search_empty_view.dart';
import 'package:registro_elettronico/core/presentation/widgets/cusotm_placeholder.dart';
import 'package:registro_elettronico/feature/didactics/presentation/text_view_page.dart';
import 'package:registro_elettronico/feature/noticeboard/data/model/attachment/attachment_file.dart';
import 'package:registro_elettronico/feature/noticeboard/domain/model/notice_domain_model.dart';
import 'package:registro_elettronico/feature/noticeboard/presentation/watcher/noticeboard_watcher_bloc.dart';
import 'package:registro_elettronico/utils/update_manager.dart';

import 'attachment/attachment_download_bloc.dart';
import 'notice_card.dart';

final GlobalKey<RefreshIndicatorState> noticeboardRefresherKey = GlobalKey();

class NoticeboardPage extends StatefulWidget {
  const NoticeboardPage({Key? key}) : super(key: key);

  @override
  _NoticeboardPageState createState() => _NoticeboardPageState();
}

class _NoticeboardPageState extends State<NoticeboardPage> {
  late SearchBar _searchBar;
  String _searchQuery = '';
  bool _unreadOnly = false;
  String _range = 'all';

  @override
  void initState() {
    _searchBar = SearchBar(
      setState: setState,
      onChanged: (query) {
        if (query.isNotEmpty) {
          setState(() => _searchQuery = query);
        }
      },
      buildDefaultAppBar: buildAppBar,
      onClosed: () {
        setState(() => _searchQuery = '');
      },
      onCleared: () {
        setState(() => _searchQuery = '');
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _searchBar.build(context),
      // key: noticeboardScaffold,
      body: RefreshIndicator(
        key: noticeboardRefresherKey,
        onRefresh: () {
          final SRUpdateManager srUpdateManager = sl();
          return srUpdateManager.updateNoticeboardData(context);
        },
        child: BlocBuilder<NoticeboardWatcherBloc, NoticeboardWatcherState>(
          builder: (context, state) {
            if (state is NoticeboardWatcherLoadSuccess) {
              if (state.notices!.isEmpty) {
                return _NoticesEmpty();
              }

              return _NoticesLoaded(
                notices: state.notices,
                query: _searchQuery,
                unreadOnly: _unreadOnly,
                range: _range,
              );
            } else if (state is NoticeboardWatcherFailure) {
              return SRFailureView(failure: state.failure);
            }

            return SRLoadingView();
          },
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        AppLocalizations.of(context)!.translate('notice_board')!,
      ),
      actions: [
        _searchBar.getSearchAction(context),
        PopupMenuButton<bool>(
          initialValue: _unreadOnly,
          icon: const Icon(Icons.filter_list),
          onSelected: (unreadOnly) {
            setState(() => _unreadOnly = unreadOnly);
          },
          itemBuilder: (context) => [
            PopupMenuItem<bool>(
              value: false,
              child: Text(
                AppLocalizations.of(context)!.translate('all_notices')!,
              ),
            ),
            PopupMenuItem<bool>(
              value: true,
              child: Text(
                AppLocalizations.of(context)!.translate('unread_notices')!,
              ),
            ),
          ],
        ),
        PopupMenuButton<String>(
          initialValue: _range,
          icon: const Icon(Icons.event_available),
          onSelected: (range) {
            setState(() => _range = range);
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'all',
              child: Text(
                AppLocalizations.of(context)!.translate('all_notices')!,
              ),
            ),
            PopupMenuItem<String>(
              value: 'active',
              child: Text(
                AppLocalizations.of(context)!.translate('active_notices')!,
              ),
            ),
            PopupMenuItem<String>(
              value: 'expired',
              child: Text(
                AppLocalizations.of(context)!.translate('expired_notices')!,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

List<NoticeDomainModel> filterNotices(
  List<NoticeDomainModel> notices, {
  required bool unreadOnly,
  String? category,
  String range = 'all',
}) {
  if (!unreadOnly &&
      (category == null || category.isEmpty) &&
      range == 'all') {
    return notices;
  }

  Iterable<NoticeDomainModel> filtered = notices;

  if (unreadOnly) {
    filtered = filtered.where((notice) => notice.readStatus != true);
  }

  if (category != null && category.isNotEmpty) {
    filtered = filtered.where((notice) => notice.contentCategory == category);
  }

  if (range == 'active') {
    filtered = filtered.where((notice) => notice.validInRange == true);
  } else if (range == 'expired') {
    filtered = filtered.where((notice) => notice.validInRange != true);
  }

  return filtered.toList();
}

class _NoticesEmpty extends StatelessWidget {
  const _NoticesEmpty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPlaceHolder(
      icon: Icons.email,
      showUpdate: true,
      onTap: () {
        noticeboardRefresherKey.currentState!.show();
      },
      text: AppLocalizations.of(context)!.translate('no_notices'),
    );
  }
}

class _NoticesLoaded extends StatefulWidget {
  final List<NoticeDomainModel>? notices;
  final String query;
  final bool unreadOnly;
  final String range;

  const _NoticesLoaded({
    Key? key,
    required this.notices,
    required this.query,
    required this.unreadOnly,
    required this.range,
  }) : super(key: key);

  @override
  State<_NoticesLoaded> createState() => _NoticesLoadedState();
}

class _NoticesLoadedState extends State<_NoticesLoaded> {
  String? _category;

  @override
  Widget build(BuildContext context) {
    List<NoticeDomainModel> noticesToShow = filterNotices(
      widget.notices!,
      unreadOnly: widget.unreadOnly,
      category: _category,
      range: widget.range,
    );

    if (widget.query.isNotEmpty && widget.query.length >= 2) {
      noticesToShow = noticesToShow
          .where((l) => _showResult(widget.query, l))
          .toList();
    }

    final categories = widget.notices!
        .map((notice) => notice.contentCategory)
        .whereType<String>()
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    if (noticesToShow.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          _buildCategoryFilter(context, categories),
          const SizedBox(
            height: 300,
            child: SrSearchEmptyView(),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: noticesToShow.length + 1,
      padding: const EdgeInsets.all(12.0),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildCategoryFilter(context, categories);
        }

        return NoticeCard(
          notice: noticesToShow[index - 1],
          showDownloadSnackbar: () {
            final snackBar = SnackBar(
              content: _DownloadAttachmentSnackbar(),
              duration: Duration(minutes: 1),
              behavior: SnackBarBehavior.floating,
            );

            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(snackBar);
          },
        );
      },
    );
  }

  Widget _buildCategoryFilter(BuildContext context, List<String> categories) {
    final selectedCategory = categories.contains(_category) ? _category : '';

    return Row(
      children: [
        Text(
          AppLocalizations.of(context)!.translate('category')!,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedCategory,
            items: [
              DropdownMenuItem<String>(
                value: '',
                child: Text(
                  AppLocalizations.of(context)!.translate('all_notices')!,
                ),
              ),
              ...categories.map(
                (category) => DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                ),
              ),
            ],
            onChanged: (category) {
              setState(() => _category = category);
            },
          ),
        ),
      ],
    );
  }

  bool _showResult(String query, NoticeDomainModel notice) {
    final lQuery = query.toLowerCase().replaceAll(' ', '');
    return notice.contentTitle!
            .toLowerCase()
            .replaceAll(' ', '')
            .contains(lQuery) ||
        notice.attachments
            .toString()
            .toLowerCase()
            .replaceAll(' ', '')
            .contains(lQuery);
  }
}

class _DownloadAttachmentSnackbar extends StatelessWidget {
  const _DownloadAttachmentSnackbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttachmentDownloadBloc, AttachmentDownloadState>(
      listener: (context, state) {
        if (state is AttachmentDownloadFailure) {
          Future.delayed(Duration(seconds: 3)).then((value) =>
              ScaffoldMessenger.of(context)..removeCurrentSnackBar());
        }

        if (state is AttachmentDownloadSuccess) {
          ScaffoldMessenger.of(context)..removeCurrentSnackBar();
        }

        if (state is AttachmentDownloadSuccess) {
          if (state.downloadedAttachment is AttachmentFile) {
            final file = state.downloadedAttachment as AttachmentFile;
            OpenFile.open(file.file.path);
          } else if (state.downloadedAttachment is AttachmentText) {
            final text = state.downloadedAttachment as AttachmentText?;

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TextViewPage(
                  text: text!.text,
                ),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        if (state is AttachmentDownloadSuccess) {
          return Text(AppLocalizations.of(context)!
              .translate('file_downloaded_success')!);
        } else if (state is AttachmentDownloadFailure) {
          return Text(
              AppLocalizations.of(context)!.translate('error_download')!);
        } else if (state is AttachmentDownloadInProgress) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.translate('downloading')!,
              ),
              Container(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  value: state.percentage,
                ),
              )
            ],
          );
        }

        return Text('');
      },
    );
  }
}
