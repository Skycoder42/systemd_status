import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:systemd_status_server/api.dart';

import '../../extensions/flutter_secure_storage_x.dart';
import '../../providers/api_provider.dart';
import '../../providers/secure_storage_provider.dart';
import '../common/startup_controller.dart';
import 'http_client_adapter_factory.dart';
import 'setup_app.dart';
import 'setup_result.dart';

final class StartupController extends StartupControllerBase {
  static const _serverUrlKey = 'serverUrl';
  static const _serverCertKey = 'serverCert';
  static const _clientConfigKey = 'clientConfig';

  @override
  Future<Uri> loadServerUrl() async {
    WidgetsFlutterBinding.ensureInitialized();

    final secureStorage = container.read(secureStorageProvider);
    final serverUrl = await secureStorage.read(key: _serverUrlKey);
    if (serverUrl != null) {
      return Uri.parse(serverUrl);
    }

    final completer = Completer<SetupResult>();
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: SetupApp(
          setupCompleter: completer,
        ),
      ),
    );

    final SetupResult(
      serverUrl: newServerUrl,
      serverCertBytes: serverCertBytes,
    ) = await completer.future;

    await secureStorage.write(
      key: _serverUrlKey,
      value: newServerUrl.toString(),
    );

    if (serverCertBytes != null) {
      await secureStorage.writeBytes(
        key: _serverCertKey,
        value: serverCertBytes,
      );
    } else {
      await secureStorage.delete(key: _serverCertKey);
    }

    return newServerUrl;
  }

  @override
  FutureOr<HttpClientAdapter?> loadHttpClientAdapter() async {
    final secureStorage = container.read(secureStorageProvider);
    final certBytes = await secureStorage.readBytes(key: _serverCertKey);
    if (certBytes == null) {
      return null;
    }

    return const HttpClientAdapterFactory().create(certBytes);
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
