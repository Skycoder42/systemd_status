import 'dart:async';
import 'dart:io';

import 'package:content_length_validator/content_length_validator.dart';
import 'package:logging/logging.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_api/shelf_api.dart' hide Options;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_helmet/shelf_helmet.dart';
import 'package:shelf_router/shelf_router.dart';

import 'api/systemd_status_api.api.dart';
import 'app/app_handler.dart';
import 'config/options.dart';
import 'config/server_config.dart';
import 'middlewares/enforce_tls.dart';
import 'middlewares/rate_limit.dart';

class Server {
  static const _maxContentLength = 1 * 1024 * 1024; // 1 MB

  final Options options;
  final _logger = Logger('Server');

  late final ProviderContainer _providerContainer;
  late final Handler _handler;
  final _signalSubs = <StreamSubscription>[];

  late final HttpServer _server;
  var _isClosing = false;

  Server(this.options) {
    _setupHandler();
    _setupSignals();
  }

  Future<void> start() async {
    _server = await serve(_handler, options.host, options.port);
    _logger.info('Listening on port ${_server.port}');
  }

  void _setupHandler() {
    _providerContainer = ProviderContainer(
      overrides: [
        optionsProvider.overrideWithValue(options),
      ],
    );

    final config = _providerContainer.read(serverConfigProvider);
    _handler = const Pipeline()
        .addMiddleware(_middlewares(config))
        .addHandler(_setupRouter(config));
  }

  Middleware _middlewares(ServerConfig config) {
    final allowedOrigins = config.allowedOrigins;
    if (allowedOrigins != null) {
      _logger.config('Enabling CORS for: $allowedOrigins');
    } else {
      _logger.config('Enabling CORS for all origins');
    }

    return (next) => const Pipeline()
        .addMiddleware(enforceTls())
        .addMiddleware(rateLimit())
        .addMiddleware(
          corsHeaders(
            originChecker: allowedOrigins != null
                ? originOneOf(allowedOrigins)
                : originAllowAll,
          ),
        )
        .addMiddleware(
          maxContentLengthValidator(
            maxContentLength: _maxContentLength,
            errorResponse: Response(HttpStatus.requestEntityTooLarge),
          ),
        )
        .addMiddleware(
          helmet(
            options: const HelmetOptions(
              enableContentSecurityPolicy: false,
            ),
          ),
        )
        .addMiddleware(handleFormatExceptions())
        .addMiddleware(logRequests(logger: _logRequest))
        .addMiddleware(rivershelfContainer(_providerContainer))
        .addHandler(next);
  }

  Handler _setupRouter(ServerConfig config) {
    final router = Router();
    if (config.appConfig.appDir case final String appDir) {
      _logger.config('Mounting app from $appDir');
      router
        ..mount(
          '/app',
          AppHandler(appDir, config.appConfig.sentryDsn).call,
        )
        ..get('/', _redirectRoot);
    }
    router.mount('/', SystemdStatusApi().call);
    return router.call;
  }

  void _logRequest(String message, bool isError) =>
      isError ? _logger.severe(message) : _logger.info(message);

  void _setupSignals() {
    for (final signal in [ProcessSignal.sigint, ProcessSignal.sigterm]) {
      _signalSubs.add(signal.watch().listen(_onSignal));
    }
  }

  Future<void> _onSignal(ProcessSignal signal) async {
    final forceClose = _isClosing;
    _isClosing = true;

    _logger.info(
      'Received signal $signal. Terminating server (force: $forceClose)...',
    );
    await _server.close(force: forceClose);

    final subs = _signalSubs.toList(); // copy the list
    _signalSubs.clear();
    await Future.wait(subs.map((s) => s.cancel()));

    _providerContainer.dispose();
  }

  Response _redirectRoot(Request request) =>
      Response.found(request.requestedUri.replace(path: '/app'));
}
