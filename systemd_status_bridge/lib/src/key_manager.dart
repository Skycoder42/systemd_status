import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:systemd_status_client/systemd_status_client.dart';

import 'options.dart';

part 'key_manager.g.dart';

@riverpod
KeyManager keyManager(KeyManagerRef ref) => KeyManager(
      ref.watch(optionsProvider),
    );

class KeyManager implements AuthenticationKeyManager {
  final Options _options;

  KeyManager(this._options);

  @override
  Future<String?> get() async {
    if (!_options.keyFile.existsSync()) {
      return null;
    }
    final key = await _options.keyFile.readAsString();
    return key.trim();
  }

  @override
  Future<void> put(String key) => Future.value();

  @override
  Future<void> remove() => Future.value();
}
