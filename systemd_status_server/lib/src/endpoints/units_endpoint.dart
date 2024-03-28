import 'package:serverpod/serverpod.dart';
import 'package:systemd_status_rpc/systemd_status_rpc.dart';

import '../config/custom_configs.dart';
import '../di/session_ref.dart';
import '../services/systemctl_service.dart';

class UnitsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<List<UnitInfo>> listUnits(Session session) async {
    final service = session.ref.read(systemctlServiceProvider);
    final units = await service.listUnits(all: true);
    return _filterUnits(units).toList();
  }

  Iterable<UnitInfo> _filterUnits(Iterable<UnitInfo> units) sync* {
    final unitFilters = pod.config.systemd.unitFilters.map(RegExp.new).toList();
    for (final unit in units) {
      for (final filter in unitFilters) {
        if (filter.hasMatch(unit.name)) {
          yield unit;
          break;
        }
      }
    }
  }
}
