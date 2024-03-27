import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:systemd_status_rpc/systemd_status_rpc.dart';

import '../../../app/theme.dart';
import 'state_icon.dart';

class UnitCard extends StatelessWidget {
  final UnitInfo unit;

  const UnitCard({
    super.key,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) => Card(
        surfaceTintColor: _activeColor(context) ?? Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StateIcon(activeState: unit.activeState),
                  const SizedBox(width: 8),
                  Text(
                    unit.name,
                    style: context.theme.textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (unit.description case final String description) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  style: context.theme.textTheme.bodySmall!.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    unit.loadState.name,
                    style: TextStyle(color: _loadColor(context)),
                  ),
                  const VerticalDivider(thickness: 2),
                  Text(
                    unit.activeState.name,
                    style: TextStyle(color: _activeColor(context)),
                  ),
                  const VerticalDivider(thickness: 2),
                  Text(unit.subState),
                ],
              ),
            ],
          ),
        ),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<UnitInfo>('unit', unit));
  }

  Color? _activeColor(BuildContext context) => switch (unit.activeState) {
        ActiveActiveState() => context.theme.colorScheme.primary,
        ReloadingActiveState() => context.theme.colorScheme.secondary,
        InactiveActiveState() => null,
        FailedActiveState() => context.theme.colorScheme.error,
        ActivatingActiveState() => context.theme.colorScheme.secondary,
        DeactivatingActiveState() => context.theme.colorScheme.secondary,
        MaintenanceActiveState() => context.theme.colorScheme.tertiary,
        UnknownActiveState() => null,
      };

  Color? _loadColor(BuildContext context) => switch (unit.loadState) {
        StubLoadState() => null,
        LoadedLoadState() => context.theme.colorScheme.primary,
        NotFoundLoadState() => context.theme.colorScheme.error,
        BadSettingLoadState() => context.theme.colorScheme.error,
        ErrorLoadState() => context.theme.colorScheme.error,
        MergedLoadState() => context.theme.colorScheme.secondary,
        MaskedLoadState() => context.theme.colorScheme.secondary,
        UnknownLoadState() => null,
      };
}
