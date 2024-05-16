import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:systemd_status_server/src/config/options.dart';
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

    // Start server
    final server = Server(options);
    await server.start();
  } on ArgParserException catch (e) {
    stderr
      ..writeln(e.message)
      ..writeln()
      ..writeln(argParser.usage);
    exit(127);
  }
}

void _printLogRecord(LogRecord event) {
  stdout.writeln(event);
  if (event.error != null) {
    stderr.writeln(event.error);
  }
  if (event.stackTrace != null) {
    stderr.writeln(event.stackTrace);
  }
}
