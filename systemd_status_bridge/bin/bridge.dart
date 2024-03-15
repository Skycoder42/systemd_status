import 'package:systemd_status_bridge/systemd_status_bridge.dart'
    as systemd_status_bridge;

Future<void> main(List<String> arguments) async {
  print('Hello world: ${systemd_status_bridge.calculate()}!');
  await Future.delayed(Duration(days: 1));
}
