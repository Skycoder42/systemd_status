import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/shared_preferences_provider.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

@freezed
class GoogleAuthSettings with _$GoogleAuthSettings {
  const factory GoogleAuthSettings({
    required String clientId,
    required String serverClientId,
    required Uri redirectUri,
  }) = _GoogleAuthSettings;

  factory GoogleAuthSettings.fromJson(Map<String, dynamic> json) =>
      _$GoogleAuthSettingsFromJson(json);
}

@freezed
class Settings with _$Settings {
  const factory Settings({
    Uri? serverUrl,
    GoogleAuthSettings? googleAuthSettings,
  }) = _Settings;
}

@Riverpod(keepAlive: true)
class AppSettings extends _$AppSettings {
  static const _serverUrlKey = 'serverUrl';
  static const _googleAuthSettingsKey = 'googleAuthSettings';

  @override
  Settings build() {
    final preferences = ref.watch(sharedPreferencesProvider);
    final serverUrl = preferences.getString(_serverUrlKey);
    final googleAuthSettings = preferences.getString(_googleAuthSettingsKey);

    return Settings(
      serverUrl: serverUrl != null ? Uri.parse(serverUrl) : null,
      googleAuthSettings: googleAuthSettings != null
          ? GoogleAuthSettings.fromJson(
              json.decode(googleAuthSettings) as Map<String, dynamic>,
            )
          : null,
    );
  }

  Future<bool> setServerUrl(Uri serverUrl) async {
    state = state.copyWith(serverUrl: serverUrl);
    return await ref
        .read(sharedPreferencesProvider)
        .setString(_serverUrlKey, serverUrl.toString());
  }

  Future<bool> removeServerUrl() async {
    state = state.copyWith(serverUrl: null);
    return await ref.read(sharedPreferencesProvider).remove(_serverUrlKey);
  }

  Future<bool> setGoogleAuthSettings(
    GoogleAuthSettings googleAuthSettings,
  ) async {
    state = state.copyWith(googleAuthSettings: googleAuthSettings);
    return await ref
        .read(sharedPreferencesProvider)
        .setString(_googleAuthSettingsKey, json.encode(googleAuthSettings));
  }

  Future<bool> removeGoogleAuthSettings() async {
    state = state.copyWith(googleAuthSettings: null);
    return await ref
        .read(sharedPreferencesProvider)
        .remove(_googleAuthSettingsKey);
  }
}
