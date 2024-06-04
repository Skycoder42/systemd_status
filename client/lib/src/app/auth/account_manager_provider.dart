import 'package:firebase_auth_rest/firebase_auth_rest.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../providers/firebase_auth_provider.dart';
import '../../providers/secure_storage_provider.dart';

part 'account_manager_provider.g.dart';

@Riverpod(keepAlive: true)
class AccountManager extends _$AccountManager {
  static const _refreshTokenKey = 'refreshToken';

  final _logger = Logger('AccountManager');

  @override
  Future<FirebaseAccount?> build() async {
    final firebaseAuth = ref.watch(firebaseAuthProvider);
    final secureStorage = ref.watch(secureStorageProvider);
    final refreshToken = await secureStorage.read(key: _refreshTokenKey);
    if (refreshToken == null) {
      return null;
    }

    try {
      final account = await firebaseAuth.restoreAccount(refreshToken);
      return account;
    } on AuthException catch (e, s) {
      _logger.severe('Failed to restore account with error:', e, s);
      return null;
    }
  }

  Future<void> signIn(String email, String password) =>
      update((oldAccount) async {
        final firebaseAuth = ref.read(firebaseAuthProvider);
        final secureStorage = ref.read(secureStorageProvider);

        final newAccount = await firebaseAuth.signInWithPassword(
          email,
          password,
        );
        try {
          await secureStorage.write(
            key: _refreshTokenKey,
            value: newAccount.refreshToken,
          );

          // TODO this does not stop the refresh timer!
          await oldAccount?.dispose();
          return newAccount;

          // ignore: avoid_catches_without_on_clauses
        } catch (e) {
          await newAccount.dispose();
          rethrow;
        }
      });

  Future<void> signOut() => update((account) async {
        final secureStorage = ref.read(secureStorageProvider);
        await secureStorage.delete(key: _refreshTokenKey);
        await account?.dispose();
        return null;
      });
}
