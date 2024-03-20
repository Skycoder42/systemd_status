import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:systemd_status_client/systemd_status_client.dart';

import 'riverpod_config.dart';

part 'key_manager.g.dart';

@riverpod
KeyManager keyManager(KeyManagerRef ref) => KeyManager(
      ref.conf((c) => c.keyPath),
    );

class KeyManager implements AuthenticationKeyManager {
  final File _keyFile;

  KeyManager(String keyPath) : _keyFile = File(keyPath);

  @override
  Future<String?> get() async {
    if (!_keyFile.existsSync()) {
      return null;
    }
    final key = await _keyFile.readAsString();
    return key.trim();
  }

  @override
  Future<void> put(String key) => Future.value();

  @override
  Future<void> remove() => Future.value();
}
