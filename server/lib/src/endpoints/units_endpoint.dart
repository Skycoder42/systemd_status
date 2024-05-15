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
}
