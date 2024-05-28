import 'dart:io';

import 'package:shelf/shelf.dart';

Middleware sentryDsn(String sentryDsn) => _SentryDsnMiddleware(sentryDsn).call;

class _SentryDsnMiddleware {
  final String _sentryDsn;

  const _SentryDsnMiddleware(this._sentryDsn);

  Handler call(Handler next) => (request) async {
        final response = await next(request);
        if (response.statusCode != HttpStatus.ok) {
          return response;
        }

        if (request.requestedUri.path != '') {
          return response;
        }

        final sentryDsnCookie = Cookie('sentryDsn', _sentryDsn)
          ..httpOnly = false
          ..secure = true
          ..sameSite = SameSite.strict;
        return response.change(
          headers: {
            HttpHeaders.setCookieHeader: sentryDsnCookie.toString(),
          },
        );
      };
}
