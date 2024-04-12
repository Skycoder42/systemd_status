import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/shared_preferences_provider.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

@freezed
class Settings with _$Settings {
  const factory Settings({
    Uri? serverUrl,
  }) = _Settings;
}

@Riverpod(keepAlive: true)
class AppSettings extends _$AppSettings {
  static const serverUrlKey = 'serverUrl';

  @override
  Settings build() {
    final preferences = ref.watch(sharedPreferencesProvider);
    return Settings(
      serverUrl: preferences.containsKey(serverUrlKey)
          ? Uri.parse(preferences.getString(serverUrlKey)!)
          : null,
    );
  }

  Future<bool> setServerUrl(Uri serverUrl) async {
    state = state.copyWith(serverUrl: serverUrl);
    return await ref
        .read(sharedPreferencesProvider)
        .setString(serverUrlKey, serverUrl.toString());
  }

  Future<bool> removeServerUrl() async {
    state = state.copyWith(serverUrl: null);
    return await ref.read(sharedPreferencesProvider).remove(serverUrlKey);
  }
}
