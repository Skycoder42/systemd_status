import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_provider.g.dart';

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) => const FlutterSecureStorage(
  aOptions: AndroidOptions.biometric(
    storageNamespace: 'de.skycoder42.systemdStatusClient',
    enforceBiometrics: true,
    biometricType: .strongBiometricOnly,
    biometricPromptTitle: 'Unlock Systemd Status',
    biometricPromptSubtitle: 'Biometrics are required to access your account',
    biometricPromptNegativeButton: 'Cancel',
  ),
  mOptions: MacOsOptions(
    accessibility: .unlocked_this_device,
    accountName: 'de.skycoder42.systemdStatusClient',
    usesDataProtectionKeychain: false,
    isInvisible: true,
  ),
  webOptions: WebOptions(
    dbName: 'de.skycoder42.systemdStatusClient',
    publicKey: 'systemd_status_secure_storage',
  ),
);
