import 'package:flutter/widgets.dart';
import 'package:systemd_status_server/api.dart';

import '../app/theme.dart';

enum StateGroup implements Comparable<StateGroup> {
  success,
  special,
  inactive,
  failure,
  transition;

  @override
  int compareTo(StateGroup other) => index.compareTo(other.index);

  Color? color(BuildContext context) => switch (this) {
        StateGroup.success => context.theme.colorScheme.primary,
        StateGroup.special => context.theme.colorScheme.secondary,
        StateGroup.inactive => null,
        StateGroup.transition => context.theme.colorScheme.tertiary,
        StateGroup.failure => context.theme.colorScheme.error,
      };
}

extension LoadStateGroupX on LoadState {
  StateGroup get group => switch (this) {
        StubLoadState() => StateGroup.special,
        LoadedLoadState() => StateGroup.success,
        NotFoundLoadState() => StateGroup.failure,
        BadSettingLoadState() => StateGroup.failure,
        ErrorLoadState() => StateGroup.failure,
        MergedLoadState() => StateGroup.special,
        MaskedLoadState() => StateGroup.special,
        UnknownLoadState() => StateGroup.inactive,
      };
}

extension ActiveStateGroupX on ActiveState {
  StateGroup get group => switch (this) {
        ActiveActiveState() => StateGroup.success,
        ReloadingActiveState() => StateGroup.transition,
        InactiveActiveState() => StateGroup.inactive,
        FailedActiveState() => StateGroup.failure,
        ActivatingActiveState() => StateGroup.transition,
        DeactivatingActiveState() => StateGroup.transition,
        MaintenanceActiveState() => StateGroup.special,
        UnknownActiveState() => StateGroup.inactive,
      };
}

extension UnitInfoStateGroupX on UnitInfo {
  StateGroup get group => ([loadState.group, activeState.group]..sort()).last;
}
