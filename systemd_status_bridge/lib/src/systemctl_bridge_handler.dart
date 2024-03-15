import 'package:systemd_status_client/systemd_status_client.dart';

class SystemctlBridgeHandler {
  Future<SerializableEntity?> call(SystemctlCommand cmd) => switch (cmd) {
        SystemctlCommand.listUnits => _listUnits(),
      };

  Future<ListUnitsResponse> _listUnits() async => ListUnitsResponse(units: []);
}
