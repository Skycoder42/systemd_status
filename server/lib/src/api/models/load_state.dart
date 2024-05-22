import 'package:freezed_annotation/freezed_annotation.dart';

part 'load_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
sealed class LoadState with _$LoadState {
  const factory LoadState.stub() = StubLoadState;
  const factory LoadState.loaded() = LoadedLoadState;
  const factory LoadState.notFound() = NotFoundLoadState;
  const factory LoadState.badSetting() = BadSettingLoadState;
  const factory LoadState.error() = ErrorLoadState;
  const factory LoadState.merged() = MergedLoadState;
  const factory LoadState.masked() = MaskedLoadState;
  const factory LoadState.unknown(String raw) = UnknownLoadState;

  factory LoadState.fromJson(String json) => switch (json) {
        'stub' => const LoadState.stub(),
        'loaded' => const LoadState.loaded(),
        'not-found' => const LoadState.notFound(),
        'bad-setting' => const LoadState.badSetting(),
        'error' => const LoadState.error(),
        'merged' => const LoadState.merged(),
        'masked' => const LoadState.masked(),
        _ => LoadState.unknown(json),
      };

  const LoadState._();

  String get name => switch (this) {
        StubLoadState() => 'stub',
        LoadedLoadState() => 'loaded',
        NotFoundLoadState() => 'not-found',
        BadSettingLoadState() => 'bad-setting',
        ErrorLoadState() => 'error',
        MergedLoadState() => 'merged',
        MaskedLoadState() => 'masked',
        UnknownLoadState(raw: final raw) => raw,
      };

  String toJson() => name;

  @override
  String toString() => name;
}
