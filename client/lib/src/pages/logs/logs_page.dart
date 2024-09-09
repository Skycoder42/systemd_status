import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:systemd_status_server/api.dart';

import 'controllers/logs_controller.dart';
import 'widgets/log_item.dart';
import 'widgets/logs_app_bar.dart';

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
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  late final PagingController<String?, JournalEntry> _pagingController;

  LogPriority? _logPriority;

  LogsQuery get _query =>
      (unitName: widget.unitName, logPriority: _logPriority);

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

  @override
  Widget build(BuildContext context) {
    _pagingController.value = ref.read(logsControllerProvider(_query));
    ref.listen(
      logsControllerProvider(_query),
      (_, next) => _pagingController.value = next,
    );
    return Scaffold(
      appBar: LogsAppBar(
        unitName: widget.unitName,
        onRefresh: () async => _refreshIndicatorKey.currentState?.show(),
        logPriority: _logPriority,
        onLogPriorityChanged: (value) => _updatePriority(
          _logPriority = value == _logPriority ? null : value,
        ),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async => ref.invalidate(logsControllerProvider(_query)),
        child: PagedListView<String?, JournalEntry>.separated(
          pagingController: _pagingController,
          primary: true,
          reverse: true,
          builderDelegate: PagedChildBuilderDelegate<JournalEntry>(
            itemBuilder: (context, item, index) => LogItem(item: item),
          ),
          separatorBuilder: (context, index) =>
              _isBoot(index) ? const Divider() : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Future<void> _loadPage(String? offset) async => await ref
      .read(logsControllerProvider(_query).notifier)
      .loadNextPage(offset);

  void _updatePriority(LogPriority? priority) {
    setState(() => _logPriority = priority);
  }

  bool _isBoot(int index) {
    final items = _pagingController.itemList ?? const [];
    final itemCount = items.length;
    if (index + 1 >= itemCount) {
      return false;
    }

    final currentItem = items[index];
    final nextItem = items[index + 1];
    return nextItem.bootId != currentItem.bootId;
  }
}
