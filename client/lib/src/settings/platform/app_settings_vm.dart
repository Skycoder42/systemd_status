import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../providers/secure_storage_provider.dart';
import '../settings.dart';
import 'app_settings_stub.dart' as stub;

mixin PlatformAppSettingsMixin on AsyncNotifier<Settings?>
    implements stub.PlatformAppSettingsMixin {
  static const _serverUrlKey = 'serverUrl';
  static const _firebaseApiKeyKey = 'firebaseApiKey';
  static const _sentryDsnKey = 'sentryDsn';

  @override
  Future<Settings?> loadSettings() async {
    final secureStorage = ref.watch(secureStorageProvider);

    final serverUrl = await secureStorage.read(key: _serverUrlKey);
    final firebaseApiKey = await secureStorage.read(key: _firebaseApiKeyKey);
    final sentryDsn = await secureStorage.read(key: _sentryDsnKey);

    if (serverUrl == null || firebaseApiKey == null) {
      return null;
    }

    return Settings(
      serverUrl: Uri.parse(serverUrl),
      firebaseApiKey: firebaseApiKey,
      sentryDsn: sentryDsn,
    );
  }

  @override
  Future<bool> updateSettings(Settings settings) async {
    final secureStorage = ref.read(secureStorageProvider);

    await secureStorage.write(
      key: _serverUrlKey,
      value: settings.serverUrl.toString(),
    );
    await secureStorage.write(
      key: _firebaseApiKeyKey,
      value: settings.firebaseApiKey,
    );
    if (settings.sentryDsn case final String sentryDsn) {
      await secureStorage.write(
        key: _sentryDsnKey,
        value: sentryDsn,
      );
    } else {
      await secureStorage.delete(key: _sentryDsnKey);
    }

    await update((_) => settings);
    return true;
  }

  @override
  Future<bool> clearSettings() async {
    final secureStorage = ref.read(secureStorageProvider);
    await Future.wait([
      secureStorage.delete(key: _serverUrlKey),
      secureStorage.delete(key: _firebaseApiKeyKey),
      secureStorage.delete(key: _sentryDsnKey),
    ]);
    return true;
  }
}
