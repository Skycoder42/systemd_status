import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_provider.g.dart';

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(SecureStorageRef ref) =>
    const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        resetOnError: true,
        sharedPreferencesName: 'secure-storage',
        preferencesKeyPrefix: 'systemd_status',
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
        publicKey: String.fromEnvironment(
          'SECURE_STORAGE_PUBLIC_KEY',
          defaultValue:
              // TODO random
              // ignore: lines_longer_than_80_chars
              'uDA870UlWCGGAotkpfzhsRuI47e40dyVPdPxfJ9t19ptpiQDOGWKkIIch+TGAlyFho8JxDlJbyOI7ddl7hHWMw==',
        ),
      ),
    );
