import 'package:freezed_annotation/freezed_annotation.dart';

part 'active_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
sealed class ActiveState with _$ActiveState {
  const factory ActiveState.active() = ActiveActiveState;
  const factory ActiveState.reloading() = ReloadingActiveState;
  const factory ActiveState.inactive() = InactiveActiveState;
  const factory ActiveState.failed() = FailedActiveState;
  const factory ActiveState.activating() = ActivatingActiveState;
  const factory ActiveState.deactivating() = DeactivatingActiveState;
  const factory ActiveState.maintenance() = MaintenanceActiveState;
  const factory ActiveState.unknown(String raw) = UnknownActiveState;

  factory ActiveState.fromJson(String json) => switch (json) {
        'active' => const ActiveState.active(),
        'reloading' => const ActiveState.reloading(),
        'inactive' => const ActiveState.inactive(),
        'failed' => const ActiveState.failed(),
        'activating' => const ActiveState.activating(),
        'deactivating' => const ActiveState.deactivating(),
        'maintenance' => const ActiveState.maintenance(),
        _ => ActiveState.unknown(json),
      };

  const ActiveState._();

  String get name => switch (this) {
        ActiveActiveState() => 'active',
        ReloadingActiveState() => 'reloading',
        InactiveActiveState() => 'inactive',
        FailedActiveState() => 'failed',
        ActivatingActiveState() => 'activating',
        DeactivatingActiveState() => 'deactivating',
        MaintenanceActiveState() => 'maintenance',
        UnknownActiveState(raw: final raw) => raw,
      };

  String toJson() => name;

  @override
  String toString() => name;
}
