import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'account_manager_provider.dart';

part 'auth_interceptor.g.dart';

@Riverpod(keepAlive: true)
AuthInterceptor authInterceptor(AuthInterceptorRef ref) => AuthInterceptor(ref);

class AuthInterceptor extends Interceptor {
  final AuthInterceptorRef _ref;

  const AuthInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final idToken = _loadIdToken();
    if (idToken == null) {
      handler.next(options);
      return;
    }

    handler.next(
      options.copyWith(
        headers: {
          ...options.headers,
          'Authorization': 'Bearer $idToken',
        },
      ),
    );
  }

  String? _loadIdToken() {
    final idToken = _ref.read(
      accountManagerProvider.select((d) => d.valueOrNull?.idToken),
    );
    return idToken;
  }
}
