import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/router.dart';
import '../../settings/app_settings.dart';
import '../../settings/settings.dart';

part 'setup_controller.freezed.dart';
part 'setup_controller.g.dart';

@freezed
sealed class SetupState with _$SetupState {
  const factory SetupState({
    required Uri? serverUrl,
    required String? firebaseApiKey,
    required String? sentryDsn,
  }) = _SetupState;

  const SetupState._();

  String get urlInput => serverUrl?.toString() ?? 'https://';
}

@riverpod
class SetupController extends _$SetupController {
  @override
  SetupState build() {
    final settings = ref.read(settingsProvider);
    return SetupState(
      serverUrl: settings?.serverUrl,
      firebaseApiKey: settings?.firebaseApiKey,
      sentryDsn: settings?.sentryDsn,
    );
  }

  Future<void> submit({
    required Uri serverUrl,
    required String firebaseApiKey,
    required String? sentryDsn,
    String? redirectTo,
  }) async {
    final appSettings = ref.read(appSettingsProvider.notifier);
    await appSettings.updateSettings(
      Settings(
        serverUrl: serverUrl,
        firebaseApiKey: firebaseApiKey,
        sentryDsn: sentryDsn,
      ),
    );

    state = state.copyWith(
      serverUrl: serverUrl,
      firebaseApiKey: firebaseApiKey,
      sentryDsn: sentryDsn,
    );

    ref.read(routerProvider).go(redirectTo ?? const RootRoute().location);
  }
}
