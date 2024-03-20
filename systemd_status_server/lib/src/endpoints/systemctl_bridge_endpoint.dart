import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class SystemctlBridgeEndpoint extends Endpoint {
  @override
  Future<void> streamOpened(StreamingSession session) async {
    session.log(
      'AUTH-KEY: ${session.authenticationKey}',
      level: LogLevel.warning,
    );
  }

  @override
  Future<void> streamClosed(StreamingSession session) async {}

  @override
  Future<void> handleStreamMessage(
    StreamingSession session,
    SerializableEntity message,
  ) async {
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
}
