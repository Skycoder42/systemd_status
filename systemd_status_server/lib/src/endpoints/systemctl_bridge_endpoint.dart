import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class SystemctlBridgeEndpoint extends Endpoint {
  static const _authKeyPasswordName = 'systemctlBridgeAuthKey';

  @override
  Future<void> streamOpened(StreamingSession session) async {
    if (!await _ensureAuthenticated(session)) {
      return;
    }
  }

  @override
  Future<void> streamClosed(StreamingSession session) async {}

  @override
  Future<void> handleStreamMessage(
    StreamingSession session,
    SerializableEntity message,
  ) async {
    if (!await _ensureAuthenticated(session)) {
      return;
    }

    try {
      switch (message) {
        case ListUnitsResponse():
          await _onListUnitsResponse(session, message);
        default:
          // TODO type
          throw Exception(
            'Invalid stream message: ${message.runtimeType}',
          );
      }
    } on Exception catch (error, stackTrace) {
      await session.close(
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _onListUnitsResponse(
    StreamingSession session,
    ListUnitsResponse response,
  ) async {
    session.log('onListUnitsResponse', level: LogLevel.debug);
  }

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
