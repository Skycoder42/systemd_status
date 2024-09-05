import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logging/logging.dart';
import 'package:systemd_status_server/api.dart';

import '../../extensions/flutter_x.dart';
import '../../localization/localization.dart';
import '../../providers/api_provider.dart';
import 'widgets/log_priority_extensions.dart';
import 'widgets/timestamp_text.dart';

class LogsPage extends ConsumerStatefulWidget {
  final String unitName;

  const LogsPage({
    super.key,
    required this.unitName,
  });

  @override
  ConsumerState<LogsPage> createState() => _LogsPageState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('unitName', unitName));
  }
}

class _LogsPageState extends ConsumerState<LogsPage> {
  static const _pageSize = 100;

  final _logger = Logger('LogsPage');

  late final PagingController<String?, JournalEntry> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: null)
      ..addPageRequestListener(_loadPage);
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _loadPage(String? offset) async {
    try {
      final api = ref.read(systemdStatusApiClientProvider);
      final newItems = await api.unitsLog(
        widget.unitName,
        offset: offset,
        count: _pageSize,
      );

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = newItems.last.cursor;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } on Exception catch (e, s) {
      _logger.severe(
        'Failed to load logs for ${widget.unitName} with offset: $offset',
        e,
        s,
      );
      _pagingController.error = e;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(context.strings.logs_page_title(widget.unitName)),
        ),
        body: RefreshIndicator(
          onRefresh: () async => _pagingController.refresh(),
          child: PagedListView<String?, JournalEntry>.separated(
            pagingController: _pagingController,
            primary: true,
            reverse: true,
            builderDelegate: PagedChildBuilderDelegate<JournalEntry>(
              itemBuilder: (context, item, index) => ListTile(
                title: Text(
                  item.message,
                  style: TextStyle(
                    color: item.priority.color,
                    fontWeight: item.priority.fontWeight,
                  ),
                ),
                subtitle: defaultTargetPlatform.isMobile
                    ? TimestampText(item.timeStamp)
                    : null,
                trailing: defaultTargetPlatform.isDesktop
                    ? TimestampText(item.timeStamp)
                    : null,
                onTap: () async => _onTap(item),
                dense: true,
              ),
            ),
            separatorBuilder: (context, index) {
              final items = _pagingController.itemList ?? const [];
              final itemCount = items.length;
              if (index + 1 >= itemCount) {
                return const SizedBox.shrink();
              }

              final currentItem = items[index];
              final nextItem = items[index + 1];
              if (nextItem.bootId == currentItem.bootId) {
                return const SizedBox.shrink();
              }

              return const Divider();
            },
          ),
        ),
      );

  Future<void> _onTap(JournalEntry entry) async {
    final messenger = ScaffoldMessenger.of(context);

    await Clipboard.setData(ClipboardData(text: entry.message));

    if (messenger.mounted) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 1),
            content: Text('Copied to clipboard!'),
          ),
        );
    }
  }
}
