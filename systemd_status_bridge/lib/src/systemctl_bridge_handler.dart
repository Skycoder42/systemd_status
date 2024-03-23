import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:systemd_status_client/systemd_status_client.dart';

import 'client_provider.dart';

part 'systemctl_bridge_handler.g.dart';

@riverpod
SystemctlBridgeHandler systemctlBridgeHandler(SystemctlBridgeHandlerRef ref) =>
    SystemctlBridgeHandler(
      ref.watch(systemdStatusSerializationManagerProvider),
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

class SystemctlBridgeHandler {
  final SerializationManager _serializationManager;
  final _logger = Logger('SystemctlBridgeHandler');

  SystemctlBridgeHandler(this._serializationManager);

  Future<SerializableEntity> call(SystemctlCommand cmd) => switch (cmd) {
        SystemctlCommand.listUnits => _listUnits(),
      };

  Future<ListUnitsResponse> _listUnits() async {
    try {
      final units = await _systemctlJson<List, List<UnitState>>(
        const [
          'list-units',
          '--all',
          '--recursive',
        ],
        fromJson: (json) => json
            .cast<Map<String, dynamic>>()
            .map((e) => UnitState.fromJson(e, _serializationManager))
            .toList(),
      );
      return ListUnitsResponse(success: true, units: units);
    } on Exception catch (e, s) {
      _logger.severe('listUnits failed with exception', e, s);
      return ListUnitsResponse(success: false, units: const []);
    }
  }

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
