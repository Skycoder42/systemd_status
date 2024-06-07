import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';

class AppHandler {
  final String _appDir;
  final String? _sentryDsn;

  late final Handler _handler;

  AppHandler(this._appDir, this._sentryDsn) {
    _handler = const Pipeline().addHandler(
      createStaticHandler(
        _appDir,
        defaultDocument: 'index.html',
        useHeaderBytesForContentType: true,
      ),
    );
  }

  FutureOr<Response> call(Request request) async {
    final result = await _handler.call(request);
    if (result.statusCode != HttpStatus.ok || _sentryDsn == null) {
      return result;
    }

    final sentryDsnCookie = Cookie('sentryDsn', _sentryDsn)
      ..httpOnly = false
      ..secure = true
      ..sameSite = SameSite.strict
      ..expires = DateTime.now().add(const Duration(days: 30));
    return result.change(
      headers: {
        HttpHeaders.setCookieHeader: sentryDsnCookie.toString(),
      },
    );
  }
}
