import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/router.dart';
import '../../settings/server_url.dart';

part 'setup_controller.freezed.dart';
part 'setup_controller.g.dart';

@freezed
sealed class SetupState with _$SetupState {
  const factory SetupState({
    required Uri? serverUrl,
  }) = _SetupState;

  const SetupState._();

  String get urlInput => serverUrl?.toString() ?? 'https://';
}

@riverpod
class SetupController extends _$SetupController {
  @override
  Future<SetupState> build() async {
    final serverUrl = await ref.read(serverUrlProvider.future);
    return SetupState(serverUrl: serverUrl);
  }

  Future<void> submit({
    required Uri serverUrl,
    String? redirectTo,
  }) async {
    await update((state) async {
      final serverUrlNotifier = ref.read(serverUrlProvider.notifier);
      await serverUrlNotifier.saveServerUrl(serverUrl);
      return state.copyWith(serverUrl: serverUrl);
    });

    ref.read(routerProvider).go(redirectTo ?? const RootRoute().location);
  }
}
