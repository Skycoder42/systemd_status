import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_provider.g.dart';

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(SecureStorageRef ref) =>
    const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        resetOnError: true,
        sharedPreferencesName: 'systemd_status_secure_storage',
        preferencesKeyPrefix: 'systemd_status_secure_storage',
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.unlocked_this_device,
        accountName: 'systemd_status_secure_storage',
      ),
      mOptions: MacOsOptions(
        accessibility: KeychainAccessibility.unlocked_this_device,
        accountName: 'systemd_status_secure_storage',
      ),
      webOptions: WebOptions(
        dbName: 'systemd_status_secure_storage',
        publicKey: 'systemd_status_secure_storage',
      ),
    );
