import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

@freezed
sealed class GoogleAuthSettings with _$GoogleAuthSettings {
  const factory GoogleAuthSettings({
    required String clientId,
    required String serverClientId,
    required Uri redirectUri,
  }) = _GoogleAuthSettings;

  factory GoogleAuthSettings.fromJson(Map<String, dynamic> json) =>
      _$GoogleAuthSettingsFromJson(json);
}

@freezed
sealed class Settings with _$Settings {
  const factory Settings({
    Uri? serverUrl,
    GoogleAuthSettings? googleAuthSettings,
    String? sentryDsn,
  }) = _Settings;
}
