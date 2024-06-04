import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:systemd_status_server/api.dart';
import 'package:web/web.dart';

import '../../providers/api_provider.dart';
import '../../providers/provider_extensions.dart';
import 'app_settings.dart';

part 'app_settings_web.g.dart';

Iterable<Override> createPlatformOverrides() => [
      settingsLoaderProvider.overrideWith(
        (ref) async {
          await ref.watch(_settingsLoaderWebProvider.future);
          return true;
        },
      ),
      settingsServerUrlProvider.overrideWithValue(
        Uri.parse(_serverUrl ?? window.location.origin),
      ),
      settingsClientConfigProvider.overrideWith(
        (ref) => ref.watch(_settingsLoaderWebProvider.selectData((c) => c)),
      ),
    ];

Future<void> persistServerUrl(Ref ref, Uri serverUrl) =>
    throw UnimplementedError();

const _serverUrl = bool.hasEnvironment('SERVER_URL')
    ? String.fromEnvironment('SERVER_URL')
    : null;

@Riverpod(keepAlive: true)
Future<ClientConfig> _settingsLoaderWeb(_SettingsLoaderWebRef ref) async =>
    await ref.watch(systemdStatusApiClientProvider).configGet();
