// ignore_for_file: invalid_annotation_target

import 'dart:io';

import 'package:checked_yaml/checked_yaml.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:serverpod_shared/serverpod_shared.dart';

import 'app_config.dart';
import 'systemd_config.dart';

part 'custom_configs.freezed.dart';
part 'custom_configs.g.dart';

@freezed
sealed class _ServerpodConfigWrapper with _$ServerpodConfigWrapper {
  @JsonSerializable(
    anyMap: true,
    checked: true,
    disallowUnrecognizedKeys: false,
  )
  const factory _ServerpodConfigWrapper({
    @JsonKey(required: true) required SystemdConfig systemd,
    required AppConfig? app,
  }) = __ServerpodConfigWrapper;

  factory _ServerpodConfigWrapper.fromJson(Map yaml) =>
      _$$_ServerpodConfigWrapperImplFromJson(yaml);
}

extension SystemdConfigX on ServerpodConfig {
  static final _loadedConfigs = Expando<_ServerpodConfigWrapper>(
    'SystemdConfig.loadedConfigs',
  );

  SystemdConfig get systemd => (_loadedConfigs[this] ??= _loadConfig()).systemd;

  AppConfig? get app => (_loadedConfigs[this] ??= _loadConfig()).app;

  _ServerpodConfigWrapper _loadConfig() {
    final configFile = File(file);
    final configString = configFile.readAsStringSync();
    final config = checkedYamlDecode<_ServerpodConfigWrapper>(
      configString,
      (yaml) => _ServerpodConfigWrapper.fromJson(yaml!),
      sourceUrl: configFile.uri,
    );
    return config;
  }
}
