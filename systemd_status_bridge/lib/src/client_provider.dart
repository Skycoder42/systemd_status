import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:systemd_status_client/systemd_status_client.dart';

import 'key_manager.dart';
import 'options.dart';

part 'client_provider.g.dart';

const _httpScheme = 'http';

@riverpod
Client systemdStatusClient(SystemdStatusClientRef ref) {
  final options = ref.watch(optionsProvider);
  final client = Client(
    Uri(scheme: _httpScheme, host: options.host, port: options.port).toString(),
    authenticationKeyManager: ref.watch(keyManagerProvider),
    connectionTimeout: const Duration(seconds: 5),
    streamingConnectionTimeout: const Duration(seconds: 5),
  );

  ref.onDispose(client.close);

  return client;
}

@riverpod
SerializationManager systemdStatusSerializationManager(
  SystemdStatusSerializationManagerRef ref,
) =>
    ref.watch(systemdStatusClientProvider).serializationManager;
