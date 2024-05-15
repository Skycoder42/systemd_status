import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf_io.dart';
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
      ..onRecord.listen(
        (event) {
          stdout.writeln(event);
          if (event.error != null) {
            stdout.writeln(event.error);
          }
          if (event.stackTrace != null) {
            stdout.writeln(event.stackTrace);
          }
        },
      );

    // Start server
    final server = Server(options);
    final httpServer = await serve(
      server.call,
      options.host,
      options.port,
    );
    // ignore: avoid_print
    Logger('Server').info('Listening on port ${httpServer.port}');
  } on ArgParserException catch (e) {
    stderr
      ..writeln(e.message)
      ..writeln()
      ..writeln(argParser.usage);
    exit(127);
  }
}
