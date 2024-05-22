import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'platform/app_settings_stub.dart'
    if (dart.library.io) 'platform/app_settings_vm.dart'
    if (dart.library.html) 'platform/app_settings_web.dart';

import 'settings.dart';

part 'app_settings.g.dart';

@Riverpod(keepAlive: true)
class AppSettings extends _$AppSettings with PlatformAppSettingsMixin {
  @override
  FutureOr<Settings?> build() => loadSettings();
}

@Riverpod(keepAlive: true)
Settings? settings(SettingsRef ref) => switch (ref.watch(appSettingsProvider)) {
      AsyncData(value: final settings) => settings,
      _ => throw StateError('appSettingsProvider has not been initialized'),
    };
