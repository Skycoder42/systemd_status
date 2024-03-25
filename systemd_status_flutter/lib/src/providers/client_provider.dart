import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:systemd_status_client/systemd_status_client.dart';

part 'client_provider.g.dart';

const _httpScheme = 'http';

@Riverpod(keepAlive: true)
Client systemdStatusClient(SystemdStatusClientRef ref) {
  final client = Client(
    // TODO debug only
    Uri(scheme: _httpScheme, host: localhost, port: 8080, path: '/').toString(),
  )..connectivityMonitor = FlutterConnectivityMonitor();

  ref.onDispose(client.close);

  return client;
}
