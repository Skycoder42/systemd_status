import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:systemd_status_server/api.dart';

import '../../../providers/api_provider.dart';

part 'logs_controller.g.dart';

typedef LogsQuery = ({
  String unitName,
  LogPriority? logPriority,
});

@riverpod
class LogsController extends _$LogsController {
  static const _pageSize = 100;

  final _logger = Logger('LogsController');

  @override
  PagingState<String?, JournalEntry> build(LogsQuery query) =>
      const PagingState();

  Future<void> loadNextPage(String? offset) async {
    try {
      final api = ref.read(systemdStatusApiClientProvider);
      final newItems = await api.unitsLog(
        query.unitName,
        priority: query.logPriority,
        offset: offset,
        count: _pageSize,
      );

      final isLastPage = newItems.length < _pageSize;
      state = PagingState(
        itemList: [...?state.itemList, ...newItems],
        nextPageKey: isLastPage ? null : newItems.last.cursor,
      );
    } on Exception catch (e, s) {
      _logger.severe(
        'Failed to load logs for ${query.unitName} with offset: $offset',
        e,
        s,
      );
      state = PagingState(
        itemList: state.itemList,
        nextPageKey: state.nextPageKey,
        error: e,
      );
    }
  }
}
