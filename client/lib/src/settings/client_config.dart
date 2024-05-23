import 'dart:async';
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:systemd_status_server/api.dart';

import '../providers/secure_storage_provider.dart';

part 'client_config.g.dart';

@Riverpod(keepAlive: true)
class ClientConfigLoader extends _$ClientConfigLoader {
  static const _clientConfigKey = 'clientConfig';

  @override
  Future<ClientConfig?> build() async {
    final secureStorage = ref.watch(secureStorageProvider);
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

  Future<void> updateConfig(ClientConfig clientConfig) async =>
      await update((_) async {
        final secureStorage = ref.watch(secureStorageProvider);
        await secureStorage.write(
          key: _clientConfigKey,
          value: json.encode(clientConfig),
        );
        return clientConfig;
      });
}
