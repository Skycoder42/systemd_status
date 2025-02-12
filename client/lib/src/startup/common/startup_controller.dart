import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_logging/sentry_logging.dart';
import 'package:systemd_status_server/api.dart';

import '../../app/app.dart';
import '../../app/auth/account_manager_provider.dart';
import '../../app/logging/log_consumer.dart';

part 'startup_controller.g.dart';

@Riverpod(keepAlive: true)
Uri serverUrl(Ref ref) => throw UnimplementedError();

@Riverpod(keepAlive: true)
HttpClientAdapter? httpClientAdapter(Ref ref) => throw UnimplementedError();

@Riverpod(keepAlive: true)
ClientConfig clientConfig(Ref ref) => throw UnimplementedError();

/// case 1: server URL exists
/// 1. Restore server URL
/// 2. Load client config from remote (with optional local cache)
/// 3. setup w/o sentry
/// 4. continue normal startup
///
/// case 2: server URL not exists
/// 1. open setup page & validate server URL
/// 2. persist server URL
/// continue with 1.2
abstract base class StartupControllerBase {
  @protected
  final logger = Logger('StartupController');

  @protected
  final ProviderContainer container = ProviderContainer(
    overrides: [
      serverUrlProvider
          .overrideWith((ref) => throw UnsupportedError('Not ready')),
      httpClientAdapterProvider
          .overrideWith((ref) => throw UnsupportedError('Not ready')),
      clientConfigProvider
          .overrideWith((ref) => throw UnsupportedError('Not ready')),
    ],
  );

  Future<void> run() async {
    _setupLogger();

    await _initOverrides();

    final sentryDsn = container.read(clientConfigProvider).sentryDsn;
    if (sentryDsn != null) {
      await _initWithSentry(sentryDsn);
      logger.config('Initialized app with sentry');
    } else {
      await _initWithoutSentry();
      logger.config('Initialized app without sentry');
    }
  }

  @protected
  FutureOr<Uri> loadServerUrl();

  @protected
  FutureOr<HttpClientAdapter?> loadHttpClientAdapter();

  @protected
  FutureOr<ClientConfig> loadClientConfig();

  void _setupLogger() {
    recordStackTraceAtLevel = Level.SEVERE;
    Logger.root.level = Level.ALL;
    unawaited(Logger.root.onRecord.pipe(LogConsumer()));
  }

  Future<void> _initOverrides() async {
    // load server url
    final serverUrl = await loadServerUrl();
    final serverCertificate = await loadHttpClientAdapter();
    container
      ..updateOverrides([
        serverUrlProvider.overrideWith((_) => serverUrl),
        httpClientAdapterProvider.overrideWith((_) => serverCertificate),
        clientConfigProvider
            .overrideWith((ref) => throw UnsupportedError('Not ready')),
      ])
      ..invalidate(serverUrlProvider);

    // load client config
    final clientConfig = await loadClientConfig();
    container
      ..updateOverrides([
        serverUrlProvider.overrideWith((_) => serverUrl),
        httpClientAdapterProvider.overrideWith((_) => serverCertificate),
        clientConfigProvider.overrideWith((_) => clientConfig),
      ])
      ..invalidate(clientConfigProvider);
  }

  Future<void> _initWithSentry(String sentryDsn) async =>
      await SentryFlutter.init(
        (options) => options
          ..dsn = sentryDsn
          ..attachThreads = true
          ..anrEnabled = true
          ..autoAppStart = false
          ..attachViewHierarchy = true
          ..addIntegration(
            LoggingIntegration(minBreadcrumbLevel: Level.CONFIG),
          ),
        appRunner: _runApp,
      );

  Future<void> _initWithoutSentry() async => await _runApp();

  Future<void> _runApp() async {
    try {
      await container.read(accountManagerProvider.future);
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      logger.warning('Failed to load account', e, s);
    }

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: DefaultAssetBundle(
          bundle: Sentry.isEnabled ? SentryAssetBundle() : rootBundle,
          child: const SystemdStatusApp(),
        ),
      ),
    );

    if (Sentry.isEnabled) {
      SentryFlutter.setAppStartEnd(DateTime.now());
    }
  }
}

final class StartupController extends StartupControllerBase {
  @override
  FutureOr<Uri> loadServerUrl() => throw UnimplementedError();

  @override
  FutureOr<HttpClientAdapter?> loadHttpClientAdapter() =>
      throw UnimplementedError();

  @override
  FutureOr<ClientConfig> loadClientConfig() => throw UnimplementedError();
}
