// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../converters/epoch_date_time_converter.dart';
import 'log_priority.dart';

part 'journal_entry.freezed.dart';
part 'journal_entry.g.dart';

@freezed
sealed class JournalEntry with _$JournalEntry {
  @EpochDateTimeConverter()
  const factory JournalEntry({
    @JsonKey(name: 'MESSAGE') required String message,
    @JsonKey(name: 'PRIORITY') required LogPriority priority,
    @JsonKey(name: '_BOOT_ID') required String bootId,
    @JsonKey(name: '_SOURCE_REALTIME_TIMESTAMP')
    required DateTime? sourceRealtimeTimestamp,
    @JsonKey(name: '__REALTIME_TIMESTAMP') required DateTime realtimeTimestamp,
    @JsonKey(name: '__CURSOR') required String cursor,
  }) = _JournalEntry;

  factory JournalEntry.fromJson(Map<String, dynamic> json) =>
      _$JournalEntryFromJson(json);

  const JournalEntry._();

  DateTime get timeStamp => sourceRealtimeTimestamp ?? realtimeTimestamp;
}
