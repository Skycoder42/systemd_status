import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:systemd_status_client/systemd_status_client.dart';
import 'package:systemd_status_rpc/systemd_status_rpc.dart';

import 'client_provider.dart';

part 'systemctl_server_impl.g.dart';

@riverpod
SystemctlServer systemctlServer(SystemctlServerRef ref) {
  final client = ref.watch(systemdStatusClientProvider);
  final rpcServer = client.systemctlBridge.createServer(
    onUnhandledError: SystemctlServerImpl._onUnhandledError,
  );
  final instance = SystemctlServerImpl(rpcServer);
  ref.onDispose(instance.close);
  return instance;
}

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

class SystemctlServerImpl extends SystemctlServer {
  static final _logger = Logger('SystemctlServer');

  SystemctlServerImpl(super.jsonRpcInstance) : super.fromServer();

  @override
  FutureOr<List<UnitInfo>> listUnits(bool all) async {
    _logger.fine('Calling listUnits');
    final units = await _systemctlJson<List, List<UnitInfo>>(
      [
        'list-units',
        if (all) '--all',
        '--recursive',
      ],
      fromJson: (json) =>
          json.cast<Map<String, dynamic>>().map(UnitInfo.fromJson).toList(),
    );
    return units;
  }

  static void _onUnhandledError(
    dynamic error,
    dynamic stackTrace,
  ) =>
      _logger.severe(
        'Unhandled JSON RPC error:',
        error,
        stackTrace as StackTrace?,
      );

  Future<TData> _systemctlJson<TJson, TData>(
    List<String> args, {
    required TData Function(TJson) fromJson,
    int? expectedExitCode = 0,
  }) =>
      _systemctlLines(
        [...args, '-ojson'],
        expectedExitCode: expectedExitCode,
      ).transform(json.decoder).cast<TJson>().map(fromJson).single;

  Stream<String> _systemctlLines(
    List<String> args, {
    int? expectedExitCode = 0,
  }) async* {
    _logger.fine('Invoking systemctl ${args.join(' ')}');
    final process = await Process.start(
      'systemctl',
      args,
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
}
