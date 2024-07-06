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
    String? sentryDsn,
  }) = _AppConfig;

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);
}

@freezed
sealed class UserInfo with _$UserInfo {
  @JsonSerializable(
    anyMap: true,
    checked: true,
    disallowUnrecognizedKeys: true,
  )
  const factory UserInfo({
    @JsonKey(required: true) required String uid,
    List<String>? unitFilters,
  }) = _UserInfo;

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);
}

@freezed
sealed class FirebaseConfig with _$FirebaseConfig {
  @JsonSerializable(
    anyMap: true,
    checked: true,
    disallowUnrecognizedKeys: true,
  )
  const factory FirebaseConfig({
    @JsonKey(required: true) required String projectId,
    @JsonKey(required: true) required String apiKey,
    List<UserInfo>? users,
  }) = _FirebaseConfig;

  factory FirebaseConfig.fromJson(Map<String, dynamic> json) =>
      _$FirebaseConfigFromJson(json);
}

@freezed
sealed class TlsConfig with _$TlsConfig {
  @JsonSerializable(
    anyMap: true,
    checked: true,
    disallowUnrecognizedKeys: true,
  )
  const factory TlsConfig({
    @JsonKey(required: true) required String pfxPath,
    String? pfxPassphrase,
  }) = _TlsConfig;

  factory TlsConfig.fromJson(Map<String, dynamic> json) =>
      _$TlsConfigFromJson(json);
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
    List<String>? unitFilters,
    TlsConfig? tls,
    @JsonKey(required: true) required AppConfig app,
    @JsonKey(required: true) required FirebaseConfig firebase,
  }) = _ServerConfig;

  factory ServerConfig.fromJson(Map<String, dynamic> json) =>
      _$ServerConfigFromJson(json);

  factory ServerConfig.fromYaml(Map? yaml) =>
      _$$ServerConfigImplFromJson(yaml!);
}
