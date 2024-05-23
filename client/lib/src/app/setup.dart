import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_logging/sentry_logging.dart';
import 'package:systemd_status_server/api.dart';

import '../settings/client_config.dart';
import '../settings/setup_loader.dart';
import 'app.dart';
import 'logging/error_observer.dart';
import 'logging/log_consumer.dart';

class Setup {
  late final ProviderContainer container = ProviderContainer(
    observers: const [ErrorObserver()],
  );
  final _logger = Logger('Setup');

  Future<void> run() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (!kDebugMode) {
      FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);
    }

    final clientConfig =
        await container.read(clientConfigLoaderProvider.future);
    if (clientConfig case ClientConfig(sentryDsn: final String sentryDsn)) {
      await _initWithSentry(sentryDsn);
      _logger.config('Initialized app with sentry');
    } else {
      await _initWithoutSentry();
      _logger.config('Initialized app without sentry');
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

  Future<void> _initWithoutSentry() async {
    Logger.root.level = Level.ALL;
    unawaited(Logger.root.onRecord.pipe(LogConsumer()));
    await _runApp();
  }

  Future<void> _runApp() async {
    try {
      _logger.finer('Loading setup configuration');
      await container.read(setupLoaderProvider.future);
      _logger.finer('Successfully loaded setup configuration');
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      _logger.warning('Failed to load setup', e, s);
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

    FlutterNativeSplash.remove();
    if (Sentry.isEnabled) {
      SentryFlutter.setAppStartEnd(DateTime.now());
    }
  }
}
