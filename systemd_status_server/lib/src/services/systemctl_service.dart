import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serverpod/serverpod.dart';
import 'package:systemd_status_rpc/systemd_status_rpc.dart';

part 'systemctl_service.g.dart';

@Riverpod(keepAlive: true)
SystemctlService systemctlService(SystemctlServiceRef ref) =>
    SystemctlService();

class SystemdStatusBridgeNotConnectedException implements Exception {
  @override
  String toString() => 'Unable to access systemd! '
      'The systemd_status_bridge is currently not connected to the server.';
}

class SystemctlService {
  Session? _session;
  SystemctlClient? _client;

  SystemctlService();

  Future<List<UnitInfo>> listUnits({bool? all}) =>
      _requireClient.listUnits(all: all);

  @internal
  Future<void> updateClient(Session session, SystemctlClient client) async {
    await closeClient();
    _session = session;
    _client = client;
    try {
      await client.listen();
    } on Exception catch (error, stackTrace) {
      session.log(
        'Systemctl client connection error',
        level: LogLevel.error,
        exception: error,
        stackTrace: stackTrace,
      );
    }
  }

  @internal
  Future<void> closeClient() async {
    try {
      await _client?.close();
      _client = null;
    } on Exception catch (error, stackTrace) {
      _session?.log(
        'Failed to close client',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
    } finally {
      _session = null;
    }
  }

  SystemctlClient get _requireClient {
    if (_client case final SystemctlClient client) {
      return client;
    }
    throw SystemdStatusBridgeNotConnectedException();
  }
}
