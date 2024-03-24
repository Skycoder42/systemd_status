import 'package:serverpod/serverpod.dart';

import '../di/session_ref.dart';
import '../services/systemctl_service.dart';

class UnitsEndpoint extends Endpoint {
  Future<String> listUnitsRaw(Session session) async {
    final service = session.ref.read(systemctlServiceProvider);
    final units = await service.listUnits();
    return units.toString();
  }
}
