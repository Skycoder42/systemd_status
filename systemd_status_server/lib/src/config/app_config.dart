// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_config.freezed.dart';
part 'app_config.g.dart';

@freezed
sealed class AppConfig with _$AppConfig {
  @JsonSerializable(
    anyMap: true,
    checked: true,
    disallowUnrecognizedKeys: true,
  )
  const factory AppConfig({
    required String? exportTo,
  }) = _AppConfig;

  factory AppConfig.fromJson(Map json) => _$$AppConfigImplFromJson(json);
}
