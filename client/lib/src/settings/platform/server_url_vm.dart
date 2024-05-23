import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../providers/secure_storage_provider.dart';
import 'server_url_stub.dart' as stub;

mixin PlatformServerUrlMixin on AsyncNotifier<Uri?>
    implements stub.PlatformServerUrlMixin {
  static const _serverUrlKey = 'serverUrl';

  @override
  Future<Uri?> loadServerUrl() async {
    final secureStorage = ref.watch(secureStorageProvider);
    final serverUrl = await secureStorage.read(key: _serverUrlKey);
    return serverUrl != null ? Uri.parse(serverUrl) : null;
  }

  @override
  Future<void> saveServerUrl(Uri serverUrl) => update((oldServerUrl) async {
        if (serverUrl == oldServerUrl) {
          return oldServerUrl;
        }

        final secureStorage = ref.read(secureStorageProvider);
        await secureStorage.write(
          key: _serverUrlKey,
          value: serverUrl.toString(),
        );
        return serverUrl;
      });

  @override
  Future<void> clearServerUrl() => update((_) async {
        final secureStorage = ref.read(secureStorageProvider);
        await secureStorage.delete(key: _serverUrlKey);
        return null;
      });
}
