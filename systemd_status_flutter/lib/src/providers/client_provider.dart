import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:systemd_status_client/systemd_status_client.dart';

import '../services/app_settings.dart';

part 'client_provider.g.dart';

class SessionManagerInitializationFailed implements Exception {
  @override
  String toString() => 'Failed to initialize session manager';
}

@Riverpod(keepAlive: true)
Client systemdStatusClient(SystemdStatusClientRef ref) {
  final serverUrl = ref.watch(appSettingsProvider.select((s) => s.serverUrl));
  if (serverUrl == null) {
    throw Exception('Unable to read server URL from settings!');
  }

  final client = Client(
    serverUrl.toString(),
    authenticationKeyManager: FlutterAuthenticationKeyManager(),
  )..connectivityMonitor = FlutterConnectivityMonitor();

  ref.onDispose(client.close);

  return client;
}

@Riverpod(keepAlive: true)
Future<Raw<SessionManager>> sessionManager(SessionManagerRef ref) async {
  final sm = SessionManager(
    caller: ref.watch(systemdStatusClientProvider).modules.auth,
  );

  if (!await sm.initialize()) {
    sm.dispose();
    throw SessionManagerInitializationFailed();
  }

  ref.onDispose(sm.dispose);
  return sm;
}

final sessionProvider = ChangeNotifierProvider<SessionManager>(
  (ref) => ref.watch(sessionManagerProvider).requireValue,
);
