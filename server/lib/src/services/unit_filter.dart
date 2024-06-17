import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/models/unit_info.dart';
import '../config/server_config.dart';
import '../middlewares/firebase_auth.dart';

part 'unit_filter.g.dart';

@Riverpod(dependencies: [userInfo])
UnitFilter unitFilter(UnitFilterRef ref) => UnitFilter(
      globalFilters:
          ref.watch(serverConfigProvider.select((c) => c.unitFilters)),
      userFilters: ref.watch(userInfoProvider.select((u) => u.unitFilters)),
    );

class UnitFilter {
  final List<RegExp>? globalFilters;
  final List<RegExp>? userFilters;

  UnitFilter({
    required Iterable<String>? globalFilters,
    required Iterable<String>? userFilters,
  })  : globalFilters = globalFilters?.map(RegExp.new).toList(),
        userFilters = userFilters?.map(RegExp.new).toList();

  Iterable<UnitInfo> call(Iterable<UnitInfo> units) sync* {
    for (final unit in units) {
      if (!_isAllowed(globalFilters, unit)) {
        continue;
      }

      if (!_isAllowed(userFilters, unit)) {
        continue;
      }

      yield unit;
    }
  }

  bool _isAllowed(Iterable<RegExp>? filters, UnitInfo unit) {
    if (filters == null) {
      return true;
    }

    for (final filter in filters) {
      if (filter.hasMatch(unit.name)) {
        return true;
      }
    }
    return false;
  }
}
