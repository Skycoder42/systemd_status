// ignore_for_file: invalid_annotation_target

import 'dart:io';

import 'package:checked_yaml/checked_yaml.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'options.dart';

part 'server_config.freezed.dart';
part 'server_config.g.dart';

@Riverpod(keepAlive: true)
ServerConfig serverConfig(ServerConfigRef ref) {
  final path = ref.watch(optionsProvider).config;
  final configFile = File(path);
  return checkedYamlDecode<ServerConfig>(
    configFile.readAsStringSync(),
    ServerConfig.fromYaml,
    sourceUrl: configFile.uri,
  );
}

@freezed
sealed class AppConfig with _$AppConfig {
  @JsonSerializable(
    anyMap: true,
    checked: true,
    disallowUnrecognizedKeys: true,
  )
  const factory AppConfig({
    String? appDir,
    @JsonKey(required: true) required String firebaseApiKey,
    String? sentryDsn,
  }) = _AppConfig;

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);
}

@freezed
sealed class ServerConfig with _$ServerConfig {
  @JsonSerializable(
    anyMap: true,
    checked: true,
    disallowUnrecognizedKeys: true,
  )
  const factory ServerConfig({
    List<String>? allowedOrigins,
    @Default([]) List<String> unitFilters,
    @JsonKey(required: true) required AppConfig appConfig,
  }) = _ServerConfig;

  factory ServerConfig.fromJson(Map<String, dynamic> json) =>
      _$ServerConfigFromJson(json);

  factory ServerConfig.fromYaml(Map? yaml) =>
      _$$ServerConfigImplFromJson(yaml!);
}
