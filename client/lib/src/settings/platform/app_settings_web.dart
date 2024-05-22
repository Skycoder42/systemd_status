import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web/web.dart';

import '../settings.dart';
import 'app_settings_stub.dart' as stub;

mixin PlatformAppSettingsMixin on AsyncNotifier<Settings?>
    implements stub.PlatformAppSettingsMixin {
  static const _serverUrl = bool.hasEnvironment('SERVER_URL')
      ? String.fromEnvironment('SERVER_URL')
      : null;
  static const _firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _sentryDsn = String.fromEnvironment('SENTRY_DSN');

  @override
  Settings loadSettings() {
    if (_firebaseApiKey.isEmpty) {
      throw StateError(
        'Web application has not been correctly configured! '
        'The FIREBASE_API_KEY is not set.',
      );
    }

    return Settings(
      serverUrl: Uri.parse(_serverUrl ?? window.location.origin),
      firebaseApiKey: _firebaseApiKey,
      sentryDsn: _sentryDsn.isNotEmpty ? _sentryDsn : null,
    );
  }

  @override
  bool updateSettings(Settings settings) => false;

  @override
  bool clearSettings() => false;
}
