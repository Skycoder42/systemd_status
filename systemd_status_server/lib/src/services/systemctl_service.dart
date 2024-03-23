import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

part 'systemctl_service.g.dart';

@Riverpod(keepAlive: true)
SystemctlService systemctlService(SystemctlServiceRef ref) =>
    SystemctlService();

abstract interface class BridgeConnector {
  Future<void> sendCommand(SystemctlCommand command);
}

class SystemctlService {
  @internal
  BridgeConnector? bridgeConnector;

  @internal
  Future<void> handleStreamMessage(SerializableEntity message) async =>
      switch (message) {
        ListUnitsResponse() => await _onListUnitsResponse(message),
        _ => throw Exception(
            'Invalid stream message: ${message.runtimeType}',
          ),
      };

  Future<void> _onListUnitsResponse(
    ListUnitsResponse response,
  ) async {}
}
