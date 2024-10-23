import 'package:posix/posix.dart' as posix;
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/models/journal_entry.dart';
import '../api/models/log_priority.dart';
import '../config/options.dart';
import 'process_runner.dart';

part 'journalctl_service.g.dart';

@riverpod
JournalctlService journalctlService(Ref ref) => JournalctlService(
      ref.watch(optionsProvider),
      ref.watch(processRunnerProvider),
    );

class JournalctlService {
  final Options _options;
  final ProcessRunner _processRunner;

  JournalctlService(this._options, this._processRunner);

  Stream<JournalEntry> streamJournal(
    String unit, {
    required int count,
    String? offset,
    LogPriority? priority,
  }) =>
      _journalctlJson(
        [
          '--unit=$unit',
          '--reverse',
          '--lines=$count',
          '--no-pager',
          '--boot=all',
          // ignore: lines_longer_than_80_chars
          '--output-fields=PRIORITY,MESSAGE,_SOURCE_REALTIME_TIMESTAMP,__REALTIME_TIMESTAMP,__CURSOR,_BOOT_ID',
          if (priority case LogPriority(level: final level))
            '--priority=$level',
          if (offset case final String curser) '--after-cursor=$curser',
        ],
        fromJson: JournalEntry.fromJson,
      );

  Stream<TData> _journalctlJson<TJson, TData>(
    List<String> args, {
    required TData Function(TJson) fromJson,
    int? expectedExitCode = 0,
  }) =>
      _processRunner.streamJson(
        _journalctlBinary,
        [
          if (_runAsUser) '--user',
          ...args,
          '--output=json',
        ],
        fromJson: fromJson,
        expectedExitCode: expectedExitCode,
      );

  String get _journalctlBinary =>
      _options.debugOverwriteJournalctl ?? 'journalctl';

  bool get _runAsUser {
    if (_options.debugOverwriteJournalctl != null) {
      return false;
    }

    return posix.geteuid() != 0;
  }
}
