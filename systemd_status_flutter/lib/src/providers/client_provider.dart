import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:systemd_status_client/systemd_status_client.dart';

part 'client_provider.g.dart';

const _httpScheme = 'http';

@Riverpod(keepAlive: true)
Client systemdStatusClient(SystemdStatusClientRef ref) {
  final client = Client(
    // TODO debug only
    Uri(scheme: _httpScheme, host: localhost, port: 8080, path: '/').toString(),
    // TODO runMode?
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
  ref.onDispose(sm.dispose);
  if (!await sm.initialize()) {
    throw Exception('Failed to initialize session manager');
  }
  return sm;
}

final sessionProvider = ChangeNotifierProvider<SessionManager>(
  (ref) => ref.watch(sessionManagerProvider).requireValue,
);
