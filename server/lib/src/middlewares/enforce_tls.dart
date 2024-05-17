import 'package:shelf/shelf.dart';

const _kReleaseMode = bool.fromEnvironment('dart.vm.product');

Middleware enforceTls({bool enabled = _kReleaseMode}) =>
    _EnforceTlsMiddleware(enabled).call;

class _EnforceTlsMiddleware {
  final bool enabled;

  const _EnforceTlsMiddleware(this.enabled);

  Handler call(Handler next) => (request) {
        if (!enabled) {
          return next(request);
        }

        if (request.requestedUri.isScheme('https') ||
            request.requestedUri.isScheme('wss')) {
          return next(request);
        } else if (request.requestedUri.isScheme('ws')) {
          return Response.movedPermanently(
            request.requestedUri.replace(scheme: 'wss'),
          );
        } else if (request.requestedUri.isScheme('http')) {
          return Response.movedPermanently(
            request.requestedUri.replace(scheme: 'https'),
          );
        } else {
          return Response.forbidden(
            'Only HTTPS and WSS are allowed as request schemes!',
          );
        }
      };
}
