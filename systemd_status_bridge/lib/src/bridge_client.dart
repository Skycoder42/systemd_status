import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:systemd_status_client/systemd_status_client.dart';

import 'client_provider.dart';
import 'systemctl_bridge_handler.dart';

part 'bridge_client.g.dart';

@riverpod
BridgeClient bridgeClient(BridgeClientRef ref) => BridgeClient(
      ref.watch(systemdStatusClientProvider),
      ref.watch(systemctlBridgeHandlerProvider),
    );

class BridgeClient {
  final Client _client;
  final SystemctlBridgeHandler _bridgeHandler;
  final _logger = Logger('BridgeClient');

  BridgeClient(
    this._client,
    this._bridgeHandler,
  );

  Future<void> run() async {
    try {
      await _client.openStreamingConnection();
      _logger.info('Successfully connected to ${_client.host}');

      await for (final message in _client.systemctlBridge.stream) {
        _logger.finer('Received message of type: ${message.runtimeType}');
        switch (message) {
          case SystemctlCommand():
            await _processCommand(message);
          default:
            _logger.warning(
              'Received invalid message of type: ${message.runtimeType}',
            );
        }
      }
    } finally {
      await _client.closeStreamingConnection();
    }
  }

  Future<void> _processCommand(SystemctlCommand message) async {
    try {
      _logger.fine('>>> Processing command: $message');
      final response = await _bridgeHandler(message);
      _logger.finer('<<< Sending reply of type: ${response.runtimeType}');
      await _client.systemctlBridge.sendStreamMessage(response);
    } on Exception catch (e, s) {
      _logger.severe('<<< Finished with exception', e, s);
    }
  }
}
