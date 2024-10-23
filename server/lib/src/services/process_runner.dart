import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'process_runner.g.dart';

class InvalidExitCode implements Exception {
  final String binary;
  final List<String> arguments;
  final int expectedExitCode;
  final int actualExitCode;

  InvalidExitCode({
    required this.binary,
    required this.arguments,
    required this.expectedExitCode,
    required this.actualExitCode,
  });

  @override
  String toString() => 'Command "$binary ${arguments.join(' ')}" failed '
      'with exit code $actualExitCode. (Expected $expectedExitCode)';
}

@riverpod
ProcessRunner processRunner(Ref ref) => ProcessRunner();

class ProcessRunner {
  final _logger = Logger('ProcessRunner');

  Stream<TData> streamJson<TJson, TData>(
    String binary,
    List<String> args, {
    required TData Function(TJson) fromJson,
    int? expectedExitCode = 0,
  }) =>
      streamLines(binary, args, expectedExitCode: expectedExitCode)
          .map(json.decode)
          .cast<TJson>()
          .map(fromJson);

  Stream<String> streamLines(
    String binary,
    List<String> args, {
    int? expectedExitCode = 0,
  }) async* {
    _logger.fine('Invoking $binary ${args.join(' ')}');
    final process = await Process.start(binary, args);

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
          binary: binary,
          arguments: args,
          expectedExitCode: expectedExitCode,
          actualExitCode: exitCode,
        );
      }
    } finally {
      await stderrSub.cancel();
    }
  }
}
