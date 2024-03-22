import 'dart:convert';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:systemd_status_client/systemd_status_client.dart';

import 'client_provider.dart';

part 'systemctl_bridge_handler.g.dart';

@riverpod
SystemctlBridgeHandler systemctlBridgeHandler(SystemctlBridgeHandlerRef ref) =>
    SystemctlBridgeHandler(
      ref.watch(systemdStatusSerializationManagerProvider),
    );

class SystemctlBridgeHandler {
  final SerializationManager _serializationManager;

  SystemctlBridgeHandler(this._serializationManager);

  Future<SerializableEntity?> call(SystemctlCommand cmd) => switch (cmd) {
        SystemctlCommand.listUnits => _listUnits(),
      };

  Future<ListUnitsResponse> _listUnits() async {
    final units = await _systemctlJson<List, List<UnitState>>(
      [
        'list-units',
        '--all',
        '--recursive',
      ],
      fromJson: (json) => json
          .cast<Map<String, dynamic>>()
          .map((e) => UnitState.fromJson(e, _serializationManager))
          .toList(),
    );
    return ListUnitsResponse(units: units);
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
      if (expectedExitCode != null && exitCode != expectedExitCode) {
        // TODO
        throw Exception('Invalid exit code: $exitCode');
      }
    } finally {
      await stderrSub.cancel();
    }
  }
}
