import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:riverpod/riverpod.dart';
import 'package:systemd_status_bridge/src/bridge_client.dart';
import 'package:systemd_status_bridge/src/options.dart';

Future<void> main(List<String> arguments) async {
  final argParser = Options.buildArgParser();
  ProviderContainer? container;
  try {
    final argResults = argParser.parse(arguments);
    final options = Options.parseOptions(argResults);

    if (options.help) {
      stdout
        ..writeln('Usage:')
        ..writeln(argParser.usage);
      return;
    }

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

    container = ProviderContainer(
      overrides: [
        optionsProvider.overrideWithValue(options),
      ],
    );

    final client = container.read(bridgeClientProvider);
    await client.run();
  } on ArgParserException catch (e) {
    stderr
      ..writeln(e.message)
      ..writeln()
      ..writeln(argParser.usage);
    exit(127);
  } finally {
    container?.dispose();
  }
}
