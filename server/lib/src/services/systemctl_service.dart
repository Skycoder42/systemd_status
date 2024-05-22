import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:posix/posix.dart' as posix;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/models/unit_info.dart';
import '../config/options.dart';

part 'systemctl_service.g.dart';

@Riverpod(keepAlive: true)
SystemctlService systemctlService(SystemctlServiceRef ref) => SystemctlService(
      ref.watch(optionsProvider),
    );

class InvalidExitCode implements Exception {
  final List<String> arguments;
  final int expectedExitCode;
  final int actualExitCode;

  InvalidExitCode({
    required this.arguments,
    required this.expectedExitCode,
    required this.actualExitCode,
  });

  @override
  String toString() => 'Command "systemctl ${arguments.join(' ')}" failed '
      'with exit code $actualExitCode. (Expected $expectedExitCode)';
}

class SystemctlService {
  final Options _options;

  final _logger = Logger('SystemctlService');

  SystemctlService(this._options);

  Future<List<UnitInfo>> listUnits({bool all = false}) async {
    _logger.fine('Calling listUnits');
    final units = await _systemctlJson<List, List<UnitInfo>>(
      [
        'list-units',
        if (all) '--all',
        '*.service',
        '*.timer',
      ],
      fromJson: UnitInfo.fromJsonList,
    );
    return units;
  }

  Future<TData> _systemctlJson<TJson, TData>(
    List<String> args, {
    required TData Function(TJson) fromJson,
    int? expectedExitCode = 0,
  }) =>
      _systemctlLines([...args, '-ojson'], expectedExitCode: expectedExitCode)
          .transform(json.decoder)
          .cast<TJson>()
          .map(fromJson)
          .single;

  Stream<String> _systemctlLines(
    List<String> args, {
    int? expectedExitCode = 0,
  }) async* {
    _logger.fine('Invoking systemctl ${args.join(' ')}');
    final process = await Process.start(
      _systemctlBinary,
      [
        if (_runAsUser) '--user',
        ...args,
      ],
    );

    final stderrSub = process.stderr
        .transform(systemEncoding.decoder)
        .transform(const LineSplitter())
        .listen(stderr.writeln);

    try {
      yield* process.stdout
          .transform(systemEncoding.decoder)
          .transform(const LineSplitter());

      final exitCode = await process.exitCode;
      _logger.fine('Finished with exit code $exitCode');
      if (expectedExitCode != null && exitCode != expectedExitCode) {
        throw InvalidExitCode(
          arguments: args,
          expectedExitCode: expectedExitCode,
          actualExitCode: exitCode,
        );
      }
    } finally {
      await stderrSub.cancel();
    }
  }

  String get _systemctlBinary =>
      _options.debugOverwriteSystemctl ?? 'systemctl';

  bool get _runAsUser {
    if (_options.debugOverwriteSystemctl != null) {
      return false;
    }

    return posix.geteuid() != 0;
  }
}
