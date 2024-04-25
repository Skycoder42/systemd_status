// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'systemd_config.freezed.dart';
part 'systemd_config.g.dart';

@freezed
sealed class SystemdConfig with _$SystemdConfig {
  @JsonSerializable(
    anyMap: true,
    checked: true,
    disallowUnrecognizedKeys: true,
  )
  const factory SystemdConfig({
    @JsonKey(required: true) required List<String> unitFilters,
  }) = _SystemdConfig;

  factory SystemdConfig.fromJson(Map yaml) =>
      _$$SystemdConfigImplFromJson(yaml);
}
