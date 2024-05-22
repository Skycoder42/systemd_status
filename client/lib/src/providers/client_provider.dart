import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:systemd_status_server/api.dart';

import '../settings/app_settings.dart';

part 'client_provider.g.dart';

class SessionManagerInitializationFailed implements Exception {
  @override
  String toString() => 'Failed to initialize session manager';
}

@Riverpod(keepAlive: true)
Dio dioClient(DioClientRef ref) {
  final serverUrl = ref.watch(settingsProvider.select((s) => s?.serverUrl));
  if (serverUrl == null) {
    throw Exception('Unable to read server URL from settings!');
  }
  final client = Dio(BaseOptions(baseUrl: serverUrl.toString()));
  ref.onDispose(() => client.close(force: true));
  return client;
}

@riverpod
SystemdStatusApiClient systemdStatusApiClient(SystemdStatusApiClientRef ref) =>
    SystemdStatusApiClient.dio(ref.watch(dioClientProvider));
