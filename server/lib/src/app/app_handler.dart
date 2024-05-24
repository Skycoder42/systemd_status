import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';

class AppHandler {
  final String appDir;

  late final Handler _handler;

  AppHandler(this.appDir) {
    // TODO add https://pub.dev/packages/shelf_host_validation for app?
    _handler = const Pipeline().addHandler(
      createStaticHandler(
        appDir,
        defaultDocument: 'index.html',
        useHeaderBytesForContentType: true,
      ),
    );
  }

  FutureOr<Response> call(Request request) async =>
      await _handler.call(request);
}
