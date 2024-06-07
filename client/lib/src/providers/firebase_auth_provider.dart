import 'package:firebase_auth_rest/firebase_auth_rest.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry/sentry.dart';

import '../app/config/app_settings.dart';

part 'firebase_auth_provider.g.dart';

@Riverpod(keepAlive: true)
http.Client httpClient(HttpClientRef ref) {
  final client = Sentry.isEnabled ? SentryHttpClient() : http.Client();
  ref.onDispose(client.close);
  return client;
}

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) => FirebaseAuth(
      ref.watch(httpClientProvider),
      ref.watch(settingsClientConfigProvider.select((c) => c.firebaseApiKey)),
    );
