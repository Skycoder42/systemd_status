import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:systemd_status_server/api.dart';

export 'app_settings_stub.dart'
    if (dart.library.html) 'app_settings_web.dart'
    if (dart.library.io) 'app_settings_vm.dart' show createPlatformOverrides;

part 'app_settings.g.dart';

@Riverpod(keepAlive: true)
Future<bool> settingsLoader(SettingsLoaderRef ref) =>
    throw UnimplementedError();

@Riverpod(keepAlive: true)
Uri settingsServerUrl(SettingsServerUrlRef ref) => throw UnimplementedError();

@Riverpod(keepAlive: true)
ClientConfig settingsClientConfig(SettingsClientConfigRef ref) =>
    throw UnimplementedError();
