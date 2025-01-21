import 'dart:async';
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
  static const defaultProcessTimeout = Duration(minutes: 1);

  final _logger = Logger('ProcessRunner');

  Future<int> exec(
    String binary,
    List<String> args, {
    int? expectedExitCode = 0,
    Duration timeout = defaultProcessTimeout,
  }) async {
    _logger.fine('Invoking $binary ${args.join(' ')}');
    final process = await Process.start(binary, args);
    final stderrSub = _pipeToStd(process.stderr);
    try {
      process.stdout.drain<void>().ignore();
      return await _waitForExit(
        process,
        binary,
        args,
        expectedExitCode,
        timeout,
      );
    } finally {
      await stderrSub.cancel();
    }
  }

  Stream<TData> streamJson<TJson, TData>(
    String binary,
    List<String> args, {
    required TData Function(TJson) fromJson,
    int? expectedExitCode = 0,
    Duration timeout = defaultProcessTimeout,
  }) =>
      streamLines(
        binary,
        args,
        expectedExitCode: expectedExitCode,
        timeout: timeout,
      ).map(json.decode).cast<TJson>().map(fromJson);

  Stream<String> streamLines(
    String binary,
    List<String> args, {
    int? expectedExitCode = 0,
    Duration timeout = defaultProcessTimeout,
  }) async* {
    _logger.fine('Invoking $binary ${args.join(' ')}');
    final process = await Process.start(binary, args);
    final stderrSub = _pipeToStd(process.stderr);
    try {
      yield* process.stdout
          .transform(systemEncoding.decoder)
          .transform(const LineSplitter());

      await _waitForExit(process, binary, args, expectedExitCode, timeout);
    } finally {
      await stderrSub.cancel();
    }
  }

  StreamSubscription<String> _pipeToStd(
    Stream<List<int>> stream, [
    Stdout? out,
  ]) =>
      stream
          .transform(systemEncoding.decoder)
          .transform(const LineSplitter())
          .listen((out ?? stderr).writeln);

  Future<int> _waitForExit(
    Process process,
    String binary,
    List<String> args,
    int? expectedExitCode,
    Duration timeout,
  ) async {
    try {
      final exitCode = await process.exitCode.timeout(timeout);
      _logger.fine('Finished with exit code $exitCode');
      if (expectedExitCode != null && exitCode != expectedExitCode) {
        throw InvalidExitCode(
          binary: binary,
          arguments: args,
          expectedExitCode: expectedExitCode,
          actualExitCode: exitCode,
        );
      }

      return exitCode;
    } on TimeoutException {
      _logger.warning('Process timed out after $timeout - sending sigterm');
      process.kill();
      rethrow;
    }
  }
}
