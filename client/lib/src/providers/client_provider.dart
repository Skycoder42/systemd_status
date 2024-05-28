import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry/sentry.dart';
import 'package:sentry_dio/sentry_dio.dart';
import 'package:systemd_status_server/api.dart';

import '../app/config/app_settings.dart';

part 'client_provider.g.dart';

@Riverpod(keepAlive: true)
Dio dioClient(DioClientRef ref) {
  final serverUrl = ref.watch(settingsServerUrlProvider);
  final client = Dio(
    BaseOptions(
      baseUrl: serverUrl.toString(),
      connectTimeout: const Duration(seconds: 30),
    ),
  );
  ref.onDispose(() => client.close(force: true));

  if (Sentry.isEnabled) {
    client.addSentry();
  }

  return client;
}

@Riverpod(keepAlive: true)
SystemdStatusApiClient systemdStatusApiClient(SystemdStatusApiClientRef ref) =>
    SystemdStatusApiClient.dio(ref.watch(dioClientProvider));
