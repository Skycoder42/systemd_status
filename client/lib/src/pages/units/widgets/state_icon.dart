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
        _loadIcon ?? _activeIcon,
        color: unit.group.color(context),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<UnitInfo>('unit', unit));
  }

  IconData? get _loadIcon => switch (unit.loadState) {
        StubLoadState() => null,
        LoadedLoadState() => null,
        NotFoundLoadState() => Icons.search_off,
        BadSettingLoadState() => Icons.warning,
        ErrorLoadState() => Icons.error,
        MergedLoadState() => Icons.merge,
        MaskedLoadState() => Icons.layers,
        UnknownLoadState() => Icons.question_mark,
      };

  IconData? get _activeIcon => switch (unit.activeState) {
        ActiveActiveState() => Icons.play_arrow,
        ReloadingActiveState() => Icons.refresh,
        InactiveActiveState() => Icons.stop,
        FailedActiveState() => Icons.error,
        ActivatingActiveState() => Icons.upload,
        DeactivatingActiveState() => Icons.download,
        MaintenanceActiveState() => Icons.miscellaneous_services,
        UnknownActiveState() => Icons.question_mark,
      };
}
