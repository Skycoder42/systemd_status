import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:sentry/sentry.dart';
import 'package:sentry_logging/sentry_logging.dart';
import 'package:systemd_status_server/gen/package_metadata.dart' as metadata;
import 'package:systemd_status_server/src/config/options.dart';
import 'package:systemd_status_server/src/config/server_config.dart';
import 'package:systemd_status_server/src/server.dart';

void main(List<String> args) async {
  // Parse arguments
  final argParser = Options.buildArgParser();
  try {
    final argResults = argParser.parse(args);
    final options = Options.parseOptions(argResults);
    if (options.help) {
      stdout
        ..writeln('Usage:')
        ..writeln(argParser.usage);
      return;
    }

    // Setup logging
    Logger.root
      ..level = options.logLevel
      ..onRecord.listen(_printLogRecord);

    // load config
    final config = ServerConfig.load(options.config);

    // start actual app (with or without sentry)
    if (config.sentryDsn case final String sentryDsn) {
      await Sentry.init(
        (options) =>
            options
              ..dsn = sentryDsn
              ..release = '${metadata.package}@${metadata.version}'
              ..attachThreads = true
              ..addIntegration(
                LoggingIntegration(minBreadcrumbLevel: Level.CONFIG),
              ),
        appRunner: () async => await _appMain(options, config),
      );
    } else {
      await _appMain(options, config);
    }
  } on ArgParserException catch (e) {
    stderr
      ..writeln(e.message)
      ..writeln()
      ..writeln(argParser.usage);
    exit(127);
  }
}

void _printLogRecord(LogRecord event) {
  stderr.writeln(event);
  if (event.error != null) {
    stderr.writeln(event.error);
  }
  if (event.stackTrace != null) {
    stderr.writeln(event.stackTrace);
  }
}

Future<void> _appMain(Options options, ServerConfig config) async {
  final server = Server(options, config);
  await server.start();
}
