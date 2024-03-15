import 'package:logging/logging.dart';
import 'package:systemd_status_bridge/src/bridge_client.dart';
import 'package:systemd_status_bridge/src/systemctl_bridge_handler.dart';

Future<void> main(List<String> arguments) async {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);

  final client = BridgeClient(SystemctlBridgeHandler());
  await client.run();
}
