import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web/web.dart';

import '../settings.dart';
import 'app_settings_stub.dart' as stub;

mixin PlatformAppSettingsMixin on Notifier<Settings>
    implements stub.PlatformAppSettingsMixin {
  @override
  Settings loadSettings() => Settings(
        serverUrl: Uri.parse(window.location.origin),
      );

  @override
  bool setServerUrl(Uri serverUrl) => false;

  @override
  bool removeServerUrl() => false;

  @override
  bool setGoogleAuthSettings(GoogleAuthSettings googleAuthSettings) => false;

  @override
  bool removeGoogleAuthSettings() => false;
}
