// ignore_for_file: invalid_annotation_target

import 'dart:io';

import 'package:checked_yaml/checked_yaml.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:serverpod_shared/serverpod_shared.dart';

import 'systemd_config.dart';

part 'custom_configs.freezed.dart';
part 'custom_configs.g.dart';

@freezed
class _ServerpodConfigWrapper with _$ServerpodConfigWrapper {
  @JsonSerializable(
    anyMap: true,
    checked: true,
    disallowUnrecognizedKeys: false,
  )
  const factory _ServerpodConfigWrapper({
    @JsonKey(required: true) required SystemdConfig systemd,
  }) = __ServerpodConfigWrapper;

  factory _ServerpodConfigWrapper.fromJson(Map yaml) =>
      _$$_ServerpodConfigWrapperImplFromJson(yaml);
}

extension SystemdConfigX on ServerpodConfig {
  static final _loadedSystemdConfigs = Expando<SystemdConfig>(
    'SystemdConfig.loadedConfigs',
  );

  SystemdConfig get systemd => _loadedSystemdConfigs[this] ??= _loadConfig();

  SystemdConfig _loadConfig() {
    final configFile = File(file);
    final configString = configFile.readAsStringSync();
    final config = checkedYamlDecode<_ServerpodConfigWrapper>(
      configString,
      (yaml) => _ServerpodConfigWrapper.fromJson(yaml!),
      sourceUrl: configFile.uri,
    );
    return config.systemd;
  }
}
