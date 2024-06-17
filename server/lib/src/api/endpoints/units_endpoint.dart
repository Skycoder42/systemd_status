import 'package:shelf_api/shelf_api.dart';

import '../../middlewares/firebase_auth.dart';
import '../../services/systemctl_service.dart';
import '../../services/unit_filter.dart';
import '../models/unit_info.dart';

@ApiEndpoint('/units', middleware: firebaseAuth)
class UnitsEndpoint extends ShelfEndpoint {
  UnitsEndpoint(super.request);

  @Get('/')
  Future<List<UnitInfo>> list({bool all = false}) async {
    final systemctlService = ref.read(systemctlServiceProvider);
    final unitFilter = ref.read(unitFilterProvider);

    final units = await systemctlService.listUnits(all: all);
    return unitFilter(units).toList();
  }
}
