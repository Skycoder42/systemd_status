import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_logging/sentry_logging.dart';

import 'app.dart';
import 'auth/account_manager_provider.dart';
import 'config/app_settings.dart';
import 'logging/error_observer.dart';
import 'logging/log_consumer.dart';

class Setup {
  late final ProviderContainer container = ProviderContainer(
    observers: const [ErrorObserver()],
    overrides: [
      ...createPlatformOverrides(),
    ],
  );
  final _logger = Logger('Setup');

  Future<void> run() async {
    recordStackTraceAtLevel = Level.SEVERE;
    Logger.root.level = Level.ALL;
    unawaited(Logger.root.onRecord.pipe(LogConsumer()));

    final sentryDsn = await _loadSettings();
    if (sentryDsn != null) {
      await _initWithSentry(sentryDsn);
      _logger.config('Initialized app with sentry');
    } else {
      await _initWithoutSentry();
      _logger.config('Initialized app without sentry');
    }
  }

  Future<String?> _loadSettings() async {
    try {
      _logger.finer('Loading setup configuration');
      await container.read(settingsLoaderProvider.future);
      _logger.finer('Successfully loaded setup configuration');
      return container
          .read(settingsClientConfigProvider.select((c) => c.sentryDsn));
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      _logger.warning('Failed to load setup', e, s);
      return null;
    }
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
      _logger.warning('Failed to load account', e, s);
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
