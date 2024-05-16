import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_api/shelf_api.dart' hide Options;
import 'package:shelf_router/shelf_router.dart';

import 'config/options.dart';
import 'systemd_status_api.api.dart';

class Server {
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

    final router = Router()..mount('/', SystemdStatusApi().call);

    _handler = const Pipeline()
        .addMiddleware(handleFormatExceptions())
        .addMiddleware(logRequests(logger: _logRequest))
        .addMiddleware(rivershelfContainer(_providerContainer))
        .addHandler(router.call);
  }

  void _setupSignals() {
    for (final signal in [ProcessSignal.sigint, ProcessSignal.sigterm]) {
      _signalSubs.add(signal.watch().listen(_onSignal));
    }
  }

  void _logRequest(String message, bool isError) =>
      isError ? _logger.severe(message) : _logger.info(message);

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
}
