import 'package:shelf_api/shelf_api.dart';

import '../../middlewares/firebase_auth.dart';
import '../../services/journalctl_service.dart';
import '../../services/systemctl_service.dart';
import '../../services/unit_filter.dart';
import '../models/journal_entry.dart';
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
  Future<List<JournalEntry>> log(
    String unit, {
    String? offset,
    int? count,
  }) async {
    if (count != null && (count < 1 || count > 500)) {
      throw const FormatException('count must be in range [1, 500]');
    }

    final journalctlService = ref.read(journalctlServiceProvider);
    final logs = await journalctlService
        .streamJournal(
          unit,
          offset: offset,
          count: count,
        )
        .toList();
    return logs;
  }
}
