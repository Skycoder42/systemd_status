import 'package:shelf_api/shelf_api.dart';

import '../models/unit_info.dart';
import '../services/systemctl_service.dart';

@ApiEndpoint('/units')
class UnitsEndpoint extends ShelfEndpoint {
  UnitsEndpoint(super.request);

  @Get('/')
  Future<List<UnitInfo>> list({bool all = false}) async {
    final systemctlService = ref.read(systemctlServiceProvider);
    return await systemctlService.listUnits(all: all);
  }

  // Iterable<UnitInfo> _filterUnits(Iterable<UnitInfo> units) sync* {
  //   final unitFilters = unitFilters.map(RegExp.new).toList();
  //   for (final unit in units) {
  //     for (final filter in unitFilters) {
  //       if (filter.hasMatch(unit.name)) {
  //         yield unit;
  //         break;
  //       }
  //     }
  //   }
  // }
}
