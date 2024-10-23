import 'dart:async';

import 'package:logging/logging.dart';
import 'package:posix/posix.dart' as posix;
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/models/unit_info.dart';
import '../config/options.dart';
import 'process_runner.dart';

part 'systemctl_service.g.dart';

@riverpod
SystemctlService systemctlService(Ref ref) => SystemctlService(
      ref.watch(optionsProvider),
      ref.watch(processRunnerProvider),
    );

class SystemctlService {
  final Options _options;
  final ProcessRunner _processRunner;

  final _logger = Logger('SystemctlService');

  SystemctlService(this._options, this._processRunner);

  Future<List<UnitInfo>> listUnits({bool all = false}) async {
    _logger.fine('Calling listUnits');
    final units = await _systemctlJson<List<dynamic>, List<UnitInfo>>(
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
  }) async =>
      await _processRunner
          .streamJson(
            _systemctlBinary,
            [
              if (_runAsUser) '--user',
              ...args,
              '--output=json',
            ],
            fromJson: fromJson,
            expectedExitCode: expectedExitCode,
          )
          .single;

  String get _systemctlBinary =>
      _options.debugOverwriteSystemctl ?? 'systemctl';

  bool get _runAsUser {
    if (_options.debugOverwriteSystemctl != null) {
      return false;
    }

    return posix.geteuid() != 0;
  }
}
