import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';

const _kReleaseMode = bool.fromEnvironment('dart.vm.product');

Middleware enforceTls({bool enabled = _kReleaseMode}) =>
    _EnforceTlsMiddleware(enabled).call;

class _EnforceTlsMiddleware {
  final bool enabled;
  final _logger = Logger('EnforceTlsMiddleware');

  // ignore: avoid_positional_boolean_parameters
  _EnforceTlsMiddleware(this.enabled);

  Handler call(Handler next) => (request) {
        if (!enabled) {
          return next(request);
        }

        final uri = request.requestedUri;
        if (uri.isScheme('https') || uri.isScheme('wss')) {
          _logger.finest('Allowing $uri');
          return next(request);
        } else if (uri.isScheme('ws')) {
          final secureUri = uri.replace(scheme: 'wss');
          _logger.finer('Redirecting $uri to $secureUri');
          return Response.movedPermanently(secureUri);
        } else if (uri.isScheme('http')) {
          final secureUri = uri.replace(scheme: 'https');
          _logger.finer('Redirecting $uri to $secureUri');
          return Response.movedPermanently(secureUri);
        } else {
          _logger.warning('Rejected unknown request scheme: ${uri.scheme}');
          return Response.forbidden(
            'Only HTTPS and WSS are allowed as request schemes!',
          );
        }
      };
}
