import 'dart:async';

import 'package:serverpod_client/serverpod_client.dart';
import 'package:stream_channel/stream_channel.dart';

extension ClientStreamChannelX on EndpointRef {
  StreamChannel<SerializableEntity> createStreamChannel() {
    resetStream();

    final controller = StreamChannelController<SerializableEntity>(
      allowForeignErrors: false,
    );
    unawaited(_setupController(controller));
    return controller.foreign;
  }

  Future<void> _setupController(
    StreamChannelController<SerializableEntity> controller,
  ) async {
    final localStreamSub = controller.local.stream.listen(
      sendStreamMessage,
      onDone: resetStream,
    );
    try {
      await stream.pipe(controller.local.sink);
    } catch (e, s) {
      controller.local.sink.addError(e, s);
      await controller.local.sink.close();
    } finally {
      await localStreamSub.cancel();
    }
  }
}
