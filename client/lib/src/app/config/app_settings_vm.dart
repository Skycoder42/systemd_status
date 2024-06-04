import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:systemd_status_server/api.dart';

import '../../providers/api_provider.dart';
import '../../providers/provider_extensions.dart';
import '../../providers/secure_storage_provider.dart';
import 'app_settings.dart';

part 'app_settings_vm.freezed.dart';
part 'app_settings_vm.g.dart';

Iterable<Override> createPlatformOverrides() => [
      settingsLoaderProvider.overrideWith(
        (ref) async => await ref.watch(_settingsLoaderVmProvider.future),
      ),
      settingsServerUrlProvider.overrideWith(
        (ref) => ref.watch(
          _localConfigProvider.selectData((c) => c.requireServerUrl),
        ),
      ),
      settingsClientConfigProvider.overrideWith(
        (ref) => ref.watch(
          _localConfigProvider.selectData((c) => c.requireClientConfig),
        ),
      ),
    ];

Future<void> persistServerUrl(Ref ref, Uri serverUrl) =>
    ref.read(_localConfigProvider.notifier).updateServerUrl(serverUrl);

@freezed
sealed class _VmConfig with _$VmConfig {
  const factory _VmConfig({
    required Uri? serverUrl,
    required ClientConfig? clientConfig,
  }) = __VmConfig;

  const _VmConfig._();

  Uri get requireServerUrl => _requiredValue('serverUrl', serverUrl);

  ClientConfig get requireClientConfig =>
      _requiredValue('clientConfig', clientConfig);

  static T _requiredValue<T>(String name, T? value) => switch (value) {
        final T value => value,
        null =>
          throw StateError('Expected $name to have a value, but was null'),
      };
}

@Riverpod(keepAlive: true)
Future<bool> _settingsLoaderVm(_SettingsLoaderVmRef ref) async {
  // load configurations from local storage
  final _VmConfig(serverUrl: serverUrl) =
      await ref.read(_localConfigProvider.future);
  // if server url is not set, configuration is needed
  if (serverUrl == null) {
    return false;
  }

  // load the current remote configuration
  final remoteConfig =
      await ref.read(systemdStatusApiClientProvider).configGet();
  // if it has changed: update the persisted config
  await ref
      .read(_localConfigProvider.notifier)
      .updateClientConfig(remoteConfig);

  return true;
}

@Riverpod(keepAlive: true)
class _LocalConfig extends _$LocalConfig {
  static const _serverUrlKey = 'serverUrl';
  static const _clientConfigKey = 'clientConfig';

  @override
  Future<_VmConfig> build() async {
    WidgetsFlutterBinding.ensureInitialized();

    final secureStorage = ref.watch(secureStorageProvider);
    final serverUrl = await secureStorage.read(key: _serverUrlKey);
    final clientConfig = await _loadClientConfigFromStorage(secureStorage);

    return _VmConfig(
      serverUrl: serverUrl != null ? Uri.parse(serverUrl) : null,
      clientConfig: clientConfig,
    );
  }

  Future<void> updateServerUrl(Uri serverUrl) => update((state) async {
        if (serverUrl == state.serverUrl) {
          return state;
        }

        final secureStorage = ref.read(secureStorageProvider);
        await secureStorage.write(
          key: _serverUrlKey,
          value: serverUrl.toString(),
        );

        return state.copyWith(serverUrl: serverUrl);
      });

  Future<void> updateClientConfig(ClientConfig clientConfig) =>
      update((state) async {
        if (clientConfig == state.clientConfig) {
          return state;
        }

        final secureStorage = ref.read(secureStorageProvider);
        await secureStorage.write(
          key: _clientConfigKey,
          value: json.encode(clientConfig),
        );

        return state.copyWith(clientConfig: clientConfig);
      });

  Future<ClientConfig?> _loadClientConfigFromStorage(
    FlutterSecureStorage secureStorage,
  ) async {
    final clientConfigString = await secureStorage.read(key: _clientConfigKey);
    if (clientConfigString != null && clientConfigString.isNotEmpty) {
      final clientConfig = ClientConfig.fromJson(
        json.decode(clientConfigString) as Map<String, dynamic>,
      );
      return clientConfig;
    } else {
      return null;
    }
  }
}
