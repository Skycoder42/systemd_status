import 'package:freezed_annotation/freezed_annotation.dart';

part 'load_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
sealed class const LoadState._() with _$LoadState {
  const factory stub() = StubLoadState;
  const factory loaded() = LoadedLoadState;
  const factory notFound() = NotFoundLoadState;
  const factory badSetting() = BadSettingLoadState;
  const factory error() = ErrorLoadState;
  const factory merged() = MergedLoadState;
  const factory masked() = MaskedLoadState;
  const factory unknown(String raw) = UnknownLoadState;

  factory fromJson(String json) => switch (json) {
    'stub' => const LoadState.stub(),
    'loaded' => const LoadState.loaded(),
    'not-found' => const LoadState.notFound(),
    'bad-setting' => const LoadState.badSetting(),
    'error' => const LoadState.error(),
    'merged' => const LoadState.merged(),
    'masked' => const LoadState.masked(),
    _ => LoadState.unknown(json),
  };

  String get name => switch (this) {
    StubLoadState() => 'stub',
    LoadedLoadState() => 'loaded',
    NotFoundLoadState() => 'not-found',
    BadSettingLoadState() => 'bad-setting',
    ErrorLoadState() => 'error',
    MergedLoadState() => 'merged',
    MaskedLoadState() => 'masked',
    UnknownLoadState(:final raw) => raw,
  };

  String toJson() => name;

  @override
  String toString() => name;
}
