import 'dart:io';

import 'package:build_cli_annotations/build_cli_annotations.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:posix/posix.dart' as posix;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'options.g.dart';

@Riverpod(keepAlive: true)
Options options(OptionsRef ref) => throw StateError('Must be overridden');

@immutable
@CliOptions()
class Options {
  static const _configName = 'systemd-status-server.yaml';

  @CliOption(
    abbr: 'H',
    valueHelp: 'address',
    defaultsTo: 'localhost',
    help: 'Specifies the host connect to.',
  )
  final String host;

  @CliOption(
    abbr: 'p',
    valueHelp: 'port',
    defaultsTo: 8080,
    help: 'Specifies the port on the host to connect to.',
  )
  final int port;

  @CliOption(
    abbr: 'c',
    valueHelp: 'path',
    help: 'The <path> to the server configuration file '
        'with additional configuration options.',
    provideDefaultToOverride: true,
  )
  final String config;

  @CliOption(
    convert: _logLevelFromString,
    abbr: 'L',
    allowed: [
      'all',
      'finest',
      'finer',
      'fine',
      'config',
      'info',
      'warning',
      'severe',
      'shout',
      'off',
    ],
    defaultsTo: 'info',
    valueHelp: 'level',
    help: 'Customize the logging level. '
        'Listed from most verbose (all) to least verbose (off).',
  )
  final Level logLevel;

  @CliOption(
    name: 'debug-overwrite-systemctl',
    hide: true,
  )
  final String? debugOverwriteSystemctl;

  @CliOption(
    name: 'debug-overwrite-journalctl',
    hide: true,
  )
  final String? debugOverwriteJournalctl;

  @CliOption(
    abbr: 'h',
    negatable: false,
    defaultsTo: false,
    help: 'Prints usage information.',
  )
  final bool help;

  const Options({
    required this.host,
    required this.port,
    required this.config,
    required this.logLevel,
    this.debugOverwriteSystemctl,
    this.debugOverwriteJournalctl,
    this.help = false,
  });

  static ArgParser buildArgParser() => _$populateOptionsParser(
        ArgParser(
          allowTrailingOptions: false,
          usageLineLength: stdout.hasTerminal ? stdout.terminalColumns : null,
        ),
        configDefaultOverride: _configDefault,
      );

  static Options parseOptions(ArgResults argResults) =>
      _$parseOptionsResult(argResults);

  static String? get _configDefault => switch (posix.geteuid() == 0) {
        true => path.join('/etc', _configName),
        false => switch (Platform.environment['XDG_CONFIG_HOME']) {
            final String xdgConfig when xdgConfig.isNotEmpty =>
              path.join(xdgConfig, _configName),
            _ => switch (Platform.environment['HOME']) {
                final String home when home.isNotEmpty =>
                  path.join(home, '.config', _configName),
                _ => null,
              }
          }
      };
}

Level _logLevelFromString(String level) =>
    Level.LEVELS.singleWhere((element) => element.name == level.toUpperCase());
