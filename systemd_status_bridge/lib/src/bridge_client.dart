import 'dart:async';

import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'client_provider.dart';
import 'systemctl_server_impl.dart';

part 'bridge_client.g.dart';

@riverpod
BridgeClient bridgeClient(BridgeClientRef ref) => BridgeClient(ref);

class BridgeClient {
  final BridgeClientRef _ref;
  final _logger = Logger('BridgeClient');

  BridgeClient(this._ref);

  Future<void> run() async {
    final client = _ref.watch(systemdStatusClientProvider);
    try {
      client.addStreamingConnectionStatusListener(_onStreamStatusChanged);
      await client.openStreamingConnection();
      _logger.fine('Successfully connected to ${client.host}');

      final systemctlServer = _ref.watch(systemctlServerProvider);
      unawaited(systemctlServer.listen());
      _logger.fine('Started systemctl rpc server');

      await systemctlServer.done;
      _logger.fine('Stopped systemctl rpc server');
    } finally {
      await client.closeStreamingConnection();
      client.removeStreamingConnectionStatusListener(_onStreamStatusChanged);
      _logger.fine('Closed streaming connection');
    }
  }

  void _onStreamStatusChanged() {
    final client = _ref.watch(systemdStatusClientProvider);
    _logger.finer(
      'Streaming connection status changed to: '
      '${client.streamingConnectionStatus}',
    );
  }
}
