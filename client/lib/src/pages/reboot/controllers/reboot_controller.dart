import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers/api_provider.dart';
import '../../../widgets/controllers/action_controller.dart';

part 'reboot_controller.g.dart';

@riverpod
class RebootController extends _$RebootController with ActionController {
  @override
  String get action => 'reboot';

  @override
  Logger get logger => Logger('RebootController');

  @override
  ActionState build() {
    ref.watch(systemdStatusApiClientProvider);
    return ActionState.hint;
  }

  @override
  Future<void> execute(CancelToken cancelToken) async {
    final api = ref.read(systemdStatusApiClientProvider);
    await api.systemReboot($cancelToken: cancelToken);
  }
}
