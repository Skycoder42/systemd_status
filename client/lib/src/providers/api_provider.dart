import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry/sentry.dart';
import 'package:sentry_dio/sentry_dio.dart';
import 'package:systemd_status_server/api.dart';

import '../app/auth/auth_interceptor.dart';
import '../startup/common/startup_controller.dart';

part 'api_provider.g.dart';

@Riverpod(keepAlive: true)
Dio dioClient(Ref ref) {
  final serverUrl = ref.watch(serverUrlProvider);
  final client = Dio(
    BaseOptions(
      baseUrl: serverUrl.toString(),
      connectTimeout: const Duration(seconds: 30),
    ),
  )..interceptors.add(ref.watch(authInterceptorProvider));

  final httpClientAdapter = ref.watch(httpClientAdapterProvider);
  if (httpClientAdapter != null) {
    client.httpClientAdapter = httpClientAdapter;
  }

  if (Sentry.isEnabled) {
    client.addSentry();
  }

  ref.onDispose(() => client.close(force: true));
  return client;
}

@Riverpod(keepAlive: true)
SystemdStatusApiClient systemdStatusApiClient(Ref ref) =>
    SystemdStatusApiClient.dio(ref.watch(dioClientProvider));
