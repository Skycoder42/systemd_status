import 'package:freezed_annotation/freezed_annotation.dart';

part 'active_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
sealed class const ActiveState._() with _$ActiveState {
  const factory active() = ActiveActiveState;
  const factory reloading() = ReloadingActiveState;
  const factory inactive() = InactiveActiveState;
  const factory failed() = FailedActiveState;
  const factory activating() = ActivatingActiveState;
  const factory deactivating() = DeactivatingActiveState;
  const factory maintenance() = MaintenanceActiveState;
  const factory unknown(String raw) = UnknownActiveState;

  factory fromJson(String json) => switch (json) {
    'active' => const ActiveState.active(),
    'reloading' => const ActiveState.reloading(),
    'inactive' => const ActiveState.inactive(),
    'failed' => const ActiveState.failed(),
    'activating' => const ActiveState.activating(),
    'deactivating' => const ActiveState.deactivating(),
    'maintenance' => const ActiveState.maintenance(),
    _ => ActiveState.unknown(json),
  };

  String get name => switch (this) {
    ActiveActiveState() => 'active',
    ReloadingActiveState() => 'reloading',
    InactiveActiveState() => 'inactive',
    FailedActiveState() => 'failed',
    ActivatingActiveState() => 'activating',
    DeactivatingActiveState() => 'deactivating',
    MaintenanceActiveState() => 'maintenance',
    UnknownActiveState(:final raw) => raw,
  };

  String toJson() => name;

  @override
  String toString() => name;
}
