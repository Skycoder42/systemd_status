import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';

import '../config/server_config.dart';
import '../middlewares/inject_flutter_config.dart';

class AppHandler {
  final AppConfig config;

  late final Handler _handler;

  AppHandler(this.config) {
    // TODO add https://pub.dev/packages/shelf_host_validation for app?
    _handler = const Pipeline()
        .addMiddleware(
          injectFlutterConfig([
            InjectConfig(
              path: 'main.dart.js',
              replacements: {
                '%{FIREBASE_API_KEY_PLACEHOLDER}': config.firebaseApiKey,
                '%{SENTRY_DSN_PLACEHOLDER}': config.sentryDsn ?? '',
              },
            ),
          ]),
        )
        .addHandler(
          createStaticHandler(
            config.appDir,
            defaultDocument: 'index.html',
            useHeaderBytesForContentType: true,
          ),
        );
  }

  FutureOr<Response> call(Request request) async =>
      await _handler.call(request);
}
