import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:systemd_status_rpc/systemd_status_rpc.dart';

class StateIcon extends StatelessWidget {
  final ActiveState activeState;

  const StateIcon({
    super.key,
    required this.activeState,
  });

  @override
  Widget build(BuildContext context) => switch (activeState) {
        ActiveActiveState() => const Icon(Icons.play_arrow),
        ReloadingActiveState() => const Icon(Icons.refresh),
        InactiveActiveState() => const Icon(Icons.stop),
        FailedActiveState() => const Icon(Icons.error),
        ActivatingActiveState() => const Icon(Icons.upload),
        DeactivatingActiveState() => const Icon(Icons.download),
        MaintenanceActiveState() => const Icon(Icons.miscellaneous_services),
        UnknownActiveState() => const Icon(Icons.question_mark),
      };

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<ActiveState>('activeState', activeState));
  }
}
