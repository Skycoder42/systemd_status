import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:systemd_status_server/api.dart';

import '../../extensions/flutter_x.dart';
import '../../localization/localization.dart';
import '../../models/state_group.dart';
import '../../providers/api_provider.dart';
import 'widgets/unit_card.dart';

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

typedef FilteredUnitParams = (String filter, bool showAll);

@riverpod
Future<List<UnitInfo>> filteredUnits(
  FilteredUnitsRef ref,
  FilteredUnitParams params,
) async {
  final units = await ref.watch(unitsProvider(params.$2).future);
  if (params.$1.isEmpty) {
    return units;
  }

  return units.where((unit) => unit.name.contains(params.$1)).toList();
}

class UnitsPage extends ConsumerStatefulWidget {
  const UnitsPage({super.key});

  @override
  ConsumerState<UnitsPage> createState() => _UnitsPageState();
}

class _UnitsPageState extends ConsumerState<UnitsPage> {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  late final SearchController _searchController;

  var _filter = '';
  var _showAll = false;

  FilteredUnitParams get _params => (_filter, _showAll);

  @override
  void initState() {
    super.initState();
    _searchController = SearchController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: switch (ref.watch(filteredUnitsProvider(_params))) {
          AsyncData(value: final units) => RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () async =>
                  ref.refresh(filteredUnitsProvider(_params).future),
              child: CustomScrollView(
                primary: true,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    title: Text(context.strings.units_page_title),
                    floating: true,
                    pinned: defaultTargetPlatform.isDesktop,
                    actions: [
                      SearchAnchor(
                        searchController: _searchController,
                        viewOnSubmitted: _updateAndClose,
                        viewTrailing: [
                          CloseButton(
                            onPressed: () => _updateAndClose(''),
                          ),
                        ],
                        builder: (context, controller) => IconButton(
                          onPressed: controller.openView,
                          icon: const Icon(Icons.search),
                        ),
                        suggestionsBuilder: (context, controller) async {
                          final units =
                              await ref.read(unitsProvider(_showAll).future);
                          return [
                            for (final unit in units)
                              if (unit.name.contains(controller.text))
                                ListTile(
                                  title: Text(unit.name),
                                  onTap: () => _updateAndClose(unit.name),
                                ),
                          ];
                        },
                      ),
                      PopupMenuButton(
                        itemBuilder: (context) => <PopupMenuEntry>[
                          CheckedPopupMenuItem(
                            checked: _showAll,
                            onTap: () => setState(() => _showAll = !_showAll),
                            child: Text(
                              context.strings.units_page_display_all_action,
                            ),
                          ),
                          if (defaultTargetPlatform.isDesktop) ...[
                            const PopupMenuDivider(),
                            PopupMenuItem(
                              child: Text(
                                context.strings.units_page_reload_action,
                              ),
                              onTap: () async =>
                                  _refreshIndicatorKey.currentState?.show(),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  SliverGrid.extent(
                    maxCrossAxisExtent: 600,
                    childAspectRatio: 2,
                    children: [
                      for (final unit in units) UnitCard(unit: unit),
                    ],
                  ),
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

  void _updateAndClose(String text) {
    _searchController.closeView(text);
    setState(() => _filter = text);
  }
}
