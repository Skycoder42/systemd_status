import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:systemd_status_server/api.dart';

import '../../../providers/api_provider.dart';

part 'logs_controller.g.dart';

typedef LogsQuery = ({String unitName, LogPriority? logPriority});

@riverpod
class LogsController extends _$LogsController {
  static const _pageSize = 100;

  final _logger = Logger('LogsController');

  @override
  PagingState<String?, JournalEntry> build(LogsQuery query) => PagingState();

  Future<void> loadNextPage() async {
    if (!state.hasNextPage || state.isLoading) {
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);
      final api = ref.read(systemdStatusApiClientProvider);
      final newItems = await api.unitsLog(
        query.unitName,
        priority: query.logPriority,
        offset: state.keys?.lastOrNull,
        count: _pageSize,
      );

      final isLastPage = newItems.length < _pageSize;
      state = state.copyWith(
        pages: newItems.isNotEmpty ? [...?state.pages, newItems] : const Omit(),
        keys:
            newItems.isNotEmpty
                ? [...?state.keys, newItems.last.cursor]
                : const Omit(),
        hasNextPage: !isLastPage,
        isLoading: false,
      );
    } on Exception catch (e, s) {
      _logger.severe(
        'Failed to load logs for ${query.unitName} with offset: '
        '${state.keys?.lastOrNull}',
        e,
        s,
      );
      state = state.copyWith(error: e, isLoading: false);
    }
  }
}

extension PagingStateX<TKey, TItem> on PagingState<TKey, TItem> {
  int get itemCount => switch (pages) {
    null => 0,
    final p => p.map((i) => i.length).fold(0, (a, b) => a + b),
  };

  Iterable<TItem> itemsIn(int index, int count) sync* {
    var offset = 0;
    var processedItems = 0;
    for (final page in pages ?? <List<TItem>>[]) {
      if (processedItems > 0) {
        if (processedItems >= count) {
          return;
        }

        yield* page.take(count - processedItems);
        processedItems += page.length;
      } else {
        final pageMax = offset + page.length;
        if (index < pageMax) {
          yield* page.skip(index - offset).take(count);
          processedItems = pageMax - index;
        }
        offset = pageMax;
      }
    }
  }
}
