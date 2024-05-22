import 'package:shelf_api/shelf_api.dart';

import '../../config/server_config.dart';
import '../../services/systemctl_service.dart';
import '../models/unit_info.dart';

@ApiEndpoint('/units')
class UnitsEndpoint extends ShelfEndpoint {
  UnitsEndpoint(super.request);

  @Get('/')
  Future<List<UnitInfo>> list({bool all = false}) async {
    final systemctlService = ref.read(systemctlServiceProvider);
    final units = await systemctlService.listUnits(all: all);
    return _filterUnits(units).toList();
  }

  Iterable<UnitInfo> _filterUnits(Iterable<UnitInfo> units) sync* {
    final unitFilters =
        ref.read(serverConfigProvider).unitFilters.map(RegExp.new).toList();
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
