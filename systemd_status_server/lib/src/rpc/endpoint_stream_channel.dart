import 'dart:async';

import 'package:meta/meta.dart';
import 'package:serverpod/serverpod.dart';
import 'package:stream_channel/stream_channel.dart';

@immutable
class _ChannelData {
  final StreamChannelController<SerializableEntity> controller;
  final StreamSubscription<SerializableEntity> localStreamSub;

  const _ChannelData({
    required this.controller,
    required this.localStreamSub,
  });

  Future<void> close() => Future.wait([
        controller.local.sink.close(),
        localStreamSub.cancel(),
      ]);
}

mixin EndpointStreamChannelMixin on Endpoint {
  final _channels = <StreamingSession, _ChannelData>{};

  @nonVirtual
  StreamChannel<SerializableEntity>? channel(StreamingSession session) =>
      _channels[session]?.controller.foreign;

  @override
  @mustCallSuper
  Future<void> streamOpened(StreamingSession session) async {
    final controller = StreamChannelController<SerializableEntity>(
      allowForeignErrors: false,
    );
    _channels[session] = _ChannelData(
      controller: controller,
      localStreamSub: controller.local.stream.listen(
        (event) => sendStreamMessage(session, event),
        onDone: () => _cleanup(session),
      ),
    );
  }

  @override
  @mustCallSuper
  Future<void> streamClosed(StreamingSession session) => _cleanup(session);

  @override
  @nonVirtual
  Future<void> handleStreamMessage(
    StreamingSession session,
    SerializableEntity message,
  ) async {
    final channel = _channels[session];
    channel?.controller.local.sink.add(message);
  }

  Future<void> _cleanup(StreamingSession session) async =>
      _channels.remove(session)?.close();
}
