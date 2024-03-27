import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:systemd_status_rpc/systemd_status_rpc.dart';

import '../../providers/client_provider.dart';
import 'widgets/unit_card.dart';

part 'units_page.g.dart';

@riverpod
Future<List<UnitInfo>> units(UnitsRef ref) =>
    ref.watch(systemdStatusClientProvider).units.listUnits();

class UnitsPage extends ConsumerWidget {
  const UnitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: switch (ref.watch(unitsProvider)) {
          AsyncData(value: final units) => RefreshIndicator(
              onRefresh: () async => ref.refresh(unitsProvider.future),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  for (final unit in units) UnitCard(unit: unit),
                ],
              ),
            ),
          AsyncError(error: final error, stackTrace: final stackTrace) =>
            Column(
              children: [
                Text(error.toString()),
                Text(stackTrace.toString()),
              ],
            ),
          _ => const Center(
              child: CircularProgressIndicator(),
            ),
        },
      );
}
