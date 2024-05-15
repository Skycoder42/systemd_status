import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/router.dart';
import '../../services/app_settings.dart';

part 'setup_controller.freezed.dart';
part 'setup_controller.g.dart';

@freezed
sealed class SetupState with _$SetupState {
  const factory SetupState({
    required Uri? serverUrl,
    required GoogleAuthSettings? googleAuthSettings,
  }) = _SetupState;

  const SetupState._();

  String get urlInput => serverUrl?.toString() ?? 'https://';
}

@riverpod
class SetupController extends _$SetupController {
  @override
  SetupState build() {
    final settings = ref.read(appSettingsProvider);
    return SetupState(
      serverUrl: settings.serverUrl,
      googleAuthSettings: settings.googleAuthSettings,
    );
  }

  Future<void> submit({
    required Uri serverUrl,
    required GoogleAuthSettings? googleAuthSettings,
    String? redirectTo,
  }) async {
    final appSettings = ref.read(appSettingsProvider.notifier);
    try {
      await appSettings.setServerUrl(serverUrl);
      // ignore: unused_result
      // await ref.refresh(sessionManagerProvider.future);

      if (googleAuthSettings != null) {
        await appSettings.setGoogleAuthSettings(googleAuthSettings);
      } else {
        await appSettings.removeGoogleAuthSettings();
      }

      state = state.copyWith(
        serverUrl: serverUrl,
        googleAuthSettings: googleAuthSettings,
      );

      ref.read(routerProvider).go(redirectTo ?? const RootRoute().location);

      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      await appSettings.removeServerUrl();
      rethrow;
    }
  }
}
