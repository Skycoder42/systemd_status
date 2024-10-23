import 'package:firebase_auth_rest/firebase_auth_rest.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry/sentry.dart';

import '../startup/startup_controller.dart';

part 'firebase_auth_provider.g.dart';

@Riverpod(keepAlive: true)
http.Client httpClient(Ref ref) {
  final client = Sentry.isEnabled ? SentryHttpClient() : http.Client();
  ref.onDispose(client.close);
  return client;
}

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth(
      ref.watch(httpClientProvider),
      ref.watch(clientConfigProvider.select((c) => c.firebaseApiKey)),
    );
