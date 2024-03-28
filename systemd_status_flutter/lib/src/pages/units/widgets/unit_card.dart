import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:systemd_status_rpc/systemd_status_rpc.dart';

import '../../../app/theme.dart';
import '../../models/state_group.dart';
import 'state_icon.dart';

class UnitCard extends StatelessWidget {
  final UnitInfo unit;

  const UnitCard({
    super.key,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) => Card(
        surfaceTintColor: unit.group.color(context) ?? Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StateIcon(unit: unit),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      unit.name,
                      style: context.theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                    style: TextStyle(
                      color: unit.loadState.group.color(context),
                    ),
                  ),
                  const VerticalDivider(thickness: 2),
                  Text(
                    unit.activeState.name,
                    style: TextStyle(
                      color: unit.activeState.group.color(context),
                    ),
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
}
