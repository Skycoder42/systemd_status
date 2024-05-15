import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:systemd_status_server/api.dart';

import '../../../models/state_group.dart';

class StateIcon extends StatelessWidget {
  final UnitInfo unit;

  const StateIcon({
    super.key,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) => Icon(
        switch (unit.activeState) {
          ActiveActiveState() => Icons.play_arrow,
          ReloadingActiveState() => Icons.refresh,
          InactiveActiveState() => Icons.stop,
          FailedActiveState() => Icons.error,
          ActivatingActiveState() => Icons.upload,
          DeactivatingActiveState() => Icons.download,
          MaintenanceActiveState() => Icons.miscellaneous_services,
          UnknownActiveState() => Icons.question_mark,
        },
        color: unit.group.color(context),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<UnitInfo>('unit', unit));
  }
}
