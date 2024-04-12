import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../providers/client_provider.dart';
import '../../services/app_settings.dart';

part 'setup_controller.freezed.dart';
part 'setup_controller.g.dart';

@freezed
class SetupState with _$SetupState {
  const factory SetupState({
    required Uri? serverUrl,
  }) = _SetupState;

  const SetupState._();

  String get urlInput => serverUrl?.toString() ?? 'https://';
}

@riverpod
class SetupController extends _$SetupController {
  @override
  SetupState build() => SetupState(
        serverUrl: ref.read(appSettingsProvider).serverUrl,
      );

  Future<void> submit({required Uri serverUrl}) async {
    final appSettings = ref.read(appSettingsProvider.notifier);
    try {
      await appSettings.setServerUrl(serverUrl);
      // ignore: unused_result
      await ref.refresh(sessionManagerProvider.future);

      state = state.copyWith(serverUrl: serverUrl);

      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      await appSettings.removeServerUrl();
      rethrow;
    }
  }
}
