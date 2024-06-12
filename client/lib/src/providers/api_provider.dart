import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry/sentry.dart';
import 'package:sentry_dio/sentry_dio.dart';
import 'package:systemd_status_server/api.dart';

import '../app/auth/auth_interceptor.dart';
import '../startup/startup_controller.dart';

part 'api_provider.g.dart';

@Riverpod(keepAlive: true)
Dio dioClient(DioClientRef ref) {
  final serverUrl = ref.watch(serverUrlProvider);
  final client = Dio(
    BaseOptions(
      baseUrl: serverUrl.toString(),
      connectTimeout: const Duration(seconds: 30),
    ),
  )..interceptors.add(ref.watch(authInterceptorProvider));
  ref.onDispose(() => client.close(force: true));

  if (Sentry.isEnabled) {
    client.addSentry();
  }

  return client;
}

@Riverpod(keepAlive: true)
SystemdStatusApiClient systemdStatusApiClient(SystemdStatusApiClientRef ref) =>
    SystemdStatusApiClient.dio(ref.watch(dioClientProvider));
