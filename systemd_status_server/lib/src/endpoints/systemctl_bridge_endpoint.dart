import 'dart:async';
import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_json_rpc_2_server/serverpod_json_rpc_2_server.dart';
import 'package:systemd_status_rpc/systemd_status_rpc.dart';

class SystemctlBridgeEndpoint extends Endpoint with EndpointStreamChannel {
  static const _authKeyPasswordName = 'systemctlBridgeAuthKey';

  @override
  Future<void> streamOpened(StreamingSession session) async {
    if (!await _ensureAuthenticated(session)) {
      return;
    }
    await super.streamOpened(session);

    final client = createClient(session);
    if (client == null) {
      session.log(
        'Failed to create RPC client for session',
        level: LogLevel.error,
      );
      return;
    }

    final systemctlClient = SystemctlClient.fromClient(client);
    unawaited(systemctlClient.listen());
    session.log('calling listUnits', level: LogLevel.info);
    unawaited(
      systemctlClient.listUnits().then(
            (units) =>
                session.log('Received units: $units', level: LogLevel.info),
          ),
    );
  }

  @override
  Future<void> streamClosed(StreamingSession session) async {
    if (!await _ensureAuthenticated(session)) {
      return;
    }
    await super.streamClosed(session);
  }

  // TODO use authentication handler
  Future<bool> _ensureAuthenticated(StreamingSession session) async {
    final actualAuthKey = session.authenticationKey;
    if (actualAuthKey == null) {
      session.log(
        'Unauthenticated! Client did not send an authentication key',
        level: LogLevel.warning,
      );
      await session.webSocket.close(WebSocketStatus.policyViolation);
      return false;
    }

    final expectedAuthKey = session.passwords[_authKeyPasswordName];
    if (expectedAuthKey == null) {
      session.log(
        'Missing $_authKeyPasswordName in passwords!',
        level: LogLevel.fatal,
      );
      await pod.shutdown();
    }

    if (actualAuthKey == expectedAuthKey) {
      session.log('Successfully authenticated.', level: LogLevel.debug);
      return true;
    }

    session.log(
      'Unauthenticated! Client sent invalid authentication key',
      level: LogLevel.warning,
    );
    await session.webSocket.close(WebSocketStatus.policyViolation);
    return false;
  }
}
