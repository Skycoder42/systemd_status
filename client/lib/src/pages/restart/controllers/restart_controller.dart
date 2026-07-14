import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers/api_provider.dart';
import '../../../widgets/controllers/action_controller.dart';

part 'restart_controller.g.dart';

@riverpod
class RestartController extends _$RestartController with ActionController {
  @override
  String get action => 'restart unit $unit';

  @override
  Logger get logger => Logger('RestartController');

  @override
  ActionState build(String unit) {
    ref.watch(systemdStatusApiClientProvider);
    return ActionState.hint;
  }

  @override
  Future<void> execute(CancelToken cancelToken) async {
    final api = ref.read(systemdStatusApiClientProvider);
    await api.unitsRestart(
      unit,
      $options: Options(
        receiveTimeout: const Duration(minutes: 1, seconds: 30),
      ),
      $cancelToken: cancelToken,
    );
  }
}
