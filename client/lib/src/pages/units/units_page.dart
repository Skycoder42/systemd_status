import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:systemd_status_server/api.dart';

import '../../models/state_group.dart';
import '../../providers/api_provider.dart';
import 'widgets/unit_card.dart';
import 'widgets/units_app_bar.dart';

part 'units_page.g.dart';

@riverpod
// ignore: avoid_positional_boolean_parameters
Future<List<UnitInfo>> units(UnitsRef ref, bool showAll) async {
  final units =
      await ref.watch(systemdStatusApiClientProvider).unitsList(all: showAll);
  units.sort((lhs, rhs) => lhs.compareTo(rhs) * -1);
  ref.keepAlive();
  return units;
}

class UnitsPage extends ConsumerStatefulWidget {
  const UnitsPage({super.key});

  @override
  ConsumerState<UnitsPage> createState() => _UnitsPageState();
}

class _UnitsPageState extends ConsumerState<UnitsPage> {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  var _filter = '';
  var _showAll = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: UnitsAppBar(
          showAll: _showAll,
          onToggleShowAll: () => setState(() => _showAll = !_showAll),
          onRefresh: () async => _refreshIndicatorKey.currentState?.show(),
          onFilterUpdated: (value) => setState(() => _filter = value),
          suggestionsBuilder: (context) async {
            final units = await ref.read(unitsProvider(_showAll).future);
            return units.map((u) => u.name);
          },
        ),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () async => ref.refresh(unitsProvider(_showAll).future),
          child: switch (ref.watch(unitsProvider(_showAll))) {
            AsyncData(value: final units) => GridView.extent(
                primary: true,
                physics: const AlwaysScrollableScrollPhysics(),
                maxCrossAxisExtent: 600,
                childAspectRatio: 2,
                children: [
                  for (final unit in units)
                    if (unit.name.contains(_filter)) UnitCard(unit: unit),
                ],
              ),
            AsyncError(error: final error, stackTrace: final stackTrace) =>
              SingleChildScrollView(
                primary: true,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Text(error.toString()),
                    Text(stackTrace.toString()),
                  ],
                ),
              ),
            _ => const Center(
                child: CircularProgressIndicator(),
              ),
          },
        ),
      );
}
