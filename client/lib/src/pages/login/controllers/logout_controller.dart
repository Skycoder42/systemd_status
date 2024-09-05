import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/auth/account_manager_provider.dart';
import '../../../app/router.dart';
import '../../../providers/secure_storage_provider.dart';

part 'logout_controller.g.dart';

enum LogoutState {
  canLogout,
  canLogoutAndReset,
  loggingOut,
}

@riverpod
class LogoutController extends _$LogoutController {
  @override
  LogoutState build() =>
      kIsWeb ? LogoutState.canLogout : LogoutState.canLogoutAndReset;

  Future<void> logOut() async {
    state = LogoutState.loggingOut;
    await ref.read(accountManagerProvider.notifier).signOut();
    ref.read(routerProvider).go(const RootRoute().location);
  }

  Future<void> reset() async {
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.deleteAll();
    scheduleMicrotask(() => exit(0));
  }
}
