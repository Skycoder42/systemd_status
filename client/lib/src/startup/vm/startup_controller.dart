import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:systemd_status_server/api.dart';

import '../../providers/api_provider.dart';
import '../../providers/secure_storage_provider.dart';
import '../common/startup_controller.dart';
import 'setup_app.dart';

final class StartupController extends StartupControllerBase {
  static const _serverUrlKey = 'serverUrl';
  static const _clientConfigKey = 'clientConfig';

  @override
  Future<Uri> loadServerUrl() async {
    WidgetsFlutterBinding.ensureInitialized();

    final secureStorage = container.read(secureStorageProvider);
    final serverUrl = await secureStorage.read(key: _serverUrlKey);
    if (serverUrl != null) {
      return Uri.parse(serverUrl);
    }

    final completer = Completer<Uri>();
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: SetupApp(
          serverUrlCompleter: completer,
        ),
      ),
    );

    final newServerUrl = await completer.future;
    await secureStorage.write(
      key: _serverUrlKey,
      value: newServerUrl.toString(),
    );
    return newServerUrl;
  }

  @override
  FutureOr<ClientConfig> loadClientConfig() async {
    try {
      final remoteConfig =
          await container.read(systemdStatusApiClientProvider).configGet();
      await _saveClientConfigInStorage(remoteConfig);
      return remoteConfig;
    } on DioException catch (e, s) {
      logger.severe('Failed to load client configuration', e, s);
      final localConfig = await _loadClientConfigFromStorage();
      if (localConfig == null) {
        throw Exception('No persisted client configuration available!');
      }
      return localConfig;
    }
  }

  Future<ClientConfig?> _loadClientConfigFromStorage() async {
    final secureStorage = container.read(secureStorageProvider);
    final clientConfigString = await secureStorage.read(key: _clientConfigKey);
    if (clientConfigString == null || clientConfigString.isEmpty) {
      return null;
    }
    return ClientConfig.fromJson(
      json.decode(clientConfigString) as Map<String, dynamic>,
    );
  }

  Future<void> _saveClientConfigInStorage(ClientConfig clientConfig) async {
    final secureStorage = container.read(secureStorageProvider);
    await secureStorage.write(
      key: _clientConfigKey,
      value: json.encode(clientConfig),
    );
  }
}
