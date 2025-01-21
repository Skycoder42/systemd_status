import 'package:shelf_api/shelf_api.dart';

import '../../middlewares/firebase_auth.dart';
import '../../services/journalctl_service.dart';
import '../../services/systemctl_service.dart';
import '../../services/unit_filter.dart';
import '../models/journal_entry.dart';
import '../models/log_priority.dart';
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

  @Get('/<unit>/logs')
  Future<TResponse<List<JournalEntry>>> log(
    String unit, {
    LogPriority? priority,
    int count = 50,
    String? offset,
  }) async {
    if (count < 1 || count > 100) {
      throw const FormatException('count must be in range [1, 100]');
    }

    if (!ref.read(unitFilterProvider).isAllowed(unit)) {
      return TResponse.forbidden(
        'User is not allowed to access logs for $unit',
      );
    }

    final journalctlService = ref.read(journalctlServiceProvider);
    final logs = await journalctlService
        .streamJournal(
          unit,
          priority: priority,
          offset: offset,
          count: count,
        )
        .toList();
    return TResponse.ok(logs);
  }

  @Post('/<unit>/restart')
  Future<TResponse<void>> restart(String unit) async {
    if (!ref.read(unitFilterProvider).isAllowed(unit)) {
      return TResponse.forbidden(
        'User is not allowed to restart $unit',
      );
    }

    final systemctlService = ref.read(systemctlServiceProvider);
    await systemctlService.restartUnit(unit);
    return TResponse.ok(null);
  }
}
