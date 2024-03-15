import 'package:logging/logging.dart';
import 'package:systemd_status_client/systemd_status_client.dart';

import 'systemctl_bridge_handler.dart';

class BridgeClient {
  final SystemctlBridgeHandler _bridgeHandler;
  final _logger = Logger('BridgeClient');

  BridgeClient(this._bridgeHandler);

  Future<void> run() async {
    final client = Client('http://localhost:8080');
    try {
      await client.openStreamingConnection();
      _logger.info('Successfully connected to ${client.host}');

      await for (final message in client.systemctlBridge.stream) {
        _logger.finer('Received message of type: ${message.runtimeType}');
        switch (message) {
          case SystemctlCommand():
            _logger.fine('>> Received command: $message');
            final response = await _bridgeHandler(message);
            if (response != null) {
              _logger.finer(
                '<< Sending response of type ${response.runtimeType}',
              );
              await client.systemctlBridge.sendStreamMessage(response);
            } else {
              _logger.finer('<< Finished without response');
            }
          default:
            _logger.warning(
              'Received invalid message of type ${message.runtimeType}',
            );
        }
      }
    } finally {
      await client.closeStreamingConnection();
      client.close();
    }
  }
}
