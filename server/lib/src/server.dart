import 'dart:async';

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_api/shelf_api.dart' hide Options;
import 'package:shelf_router/shelf_router.dart';

import 'config/options.dart';
import 'systemd_status_api.api.dart';

class Server {
  static final _logger = Logger('Server');

  final Options options;

  late final Handler _pipeline;

  Server(this.options) {
    final router = Router()..mount('/', SystemdStatusApi().call);

    _pipeline = const Pipeline()
        .addMiddleware(handleFormatExceptions())
        .addMiddleware(logRequests(logger: _logRequest))
        .addMiddleware(
          rivershelf(
            overrides: [
              optionsProvider.overrideWithValue(options),
            ],
          ),
        )
        .addHandler(router.call);
  }

  FutureOr<Response> call(Request request) => _pipeline(request);

  void _logRequest(String message, bool isError) =>
      isError ? _logger.severe(message) : _logger.info(message);
}
