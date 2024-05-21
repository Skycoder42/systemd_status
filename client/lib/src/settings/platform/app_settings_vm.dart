import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../providers/shared_preferences_provider.dart';
import '../settings.dart';
import 'app_settings_stub.dart' as stub;

mixin PlatformAppSettingsMixin on Notifier<Settings>
    implements stub.PlatformAppSettingsMixin {
  static const _serverUrlKey = 'serverUrl';
  static const _googleAuthSettingsKey = 'googleAuthSettings';

  @override
  Settings loadSettings() {
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

  @override
  Future<bool> setServerUrl(Uri serverUrl) async {
    state = state.copyWith(serverUrl: serverUrl);
    return await ref
        .read(sharedPreferencesProvider)
        .setString(_serverUrlKey, serverUrl.toString());
  }

  @override
  Future<bool> removeServerUrl() async {
    state = state.copyWith(serverUrl: null);
    return await ref.read(sharedPreferencesProvider).remove(_serverUrlKey);
  }

  @override
  Future<bool> setGoogleAuthSettings(
    GoogleAuthSettings googleAuthSettings,
  ) async {
    state = state.copyWith(googleAuthSettings: googleAuthSettings);
    return await ref
        .read(sharedPreferencesProvider)
        .setString(_googleAuthSettingsKey, json.encode(googleAuthSettings));
  }

  @override
  Future<bool> removeGoogleAuthSettings() async {
    state = state.copyWith(googleAuthSettings: null);
    return await ref
        .read(sharedPreferencesProvider)
        .remove(_googleAuthSettingsKey);
  }
}
