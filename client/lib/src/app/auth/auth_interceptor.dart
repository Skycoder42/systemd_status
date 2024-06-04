import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/app_settings.dart';
import 'account_manager_provider.dart';

part 'auth_interceptor.g.dart';

@Riverpod(keepAlive: true)
AuthInterceptor authInterceptor(AuthInterceptorRef ref) => AuthInterceptor(ref);

class AuthInterceptor extends Interceptor {
  final AuthInterceptorRef _ref;

  const AuthInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final isInitialized = _ref.read(
      settingsLoaderProvider.select((d) => d.valueOrNull ?? false),
    );
    if (!isInitialized) {
      handler.next(options);
      return;
    }

    final account = _ref.read(
      accountManagerProvider.select((d) => d.valueOrNull),
    );
    if (account == null) {
      handler.next(options);
      return;
    }

    handler.next(
      options.copyWith(
        headers: {
          ...options.headers,
          'Authorization': 'Bearer ${account.idToken}',
        },
      ),
    );
  }
}
