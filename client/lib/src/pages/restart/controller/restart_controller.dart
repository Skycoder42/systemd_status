import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers/api_provider.dart';

part 'restart_controller.g.dart';

enum RestartState {
  hint,
  pending,
  success,
  failure,
}

@riverpod
class RestartController extends _$RestartController {
  final _logger = Logger('RestartController');

  @override
  RestartState build(String unit) {
    ref.watch(systemdStatusApiClientProvider);
    return RestartState.hint;
  }

  Future<void> restart() async {
    final api = ref.read(systemdStatusApiClientProvider);
    try {
      state = RestartState.pending;
      final cancelToken = CancelToken();
      ref.onDispose(cancelToken.cancel);
      await api.unitsRestart(
        unit,
        $options: Options(
          receiveTimeout: const Duration(minutes: 1, seconds: 30),
        ),
        $cancelToken: cancelToken,
      );
      state = RestartState.success;
    } on Exception catch (e, s) {
      if (e case DioException(type: DioExceptionType.cancel)) {
        state = RestartState.hint;
        return;
      }

      _logger.severe('Failed to restart unit $unit', e, s);
      state = RestartState.failure;
    }
  }
}
