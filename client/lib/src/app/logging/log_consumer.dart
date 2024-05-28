// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:developer';

import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class LogConsumer implements StreamConsumer<LogRecord> {
  @override
  Future<void> addStream(Stream<LogRecord> stream) => stream.forEach(_onRecord);

  @override
  Future<void> close() => Future.value();

  void _onRecord(LogRecord logRecord) {
    if (kDebugMode) {
      log(
        _coloredMessage(logRecord),
        error: logRecord.error,
        level: logRecord.level.value,
        name: logRecord.loggerName,
        sequenceNumber: logRecord.sequenceNumber,
        stackTrace: logRecord.stackTrace,
        time: logRecord.time,
        zone: logRecord.zone,
      );
    }

    print(_coloredMessage(logRecord, logRecord.toString()));
    if (logRecord.error != null) {
      print(_coloredMessage(logRecord, logRecord.error.toString()));
    }
    if (logRecord.stackTrace != null) {
      print(_coloredMessage(logRecord, logRecord.stackTrace.toString()));
    }
  }

  String _coloredMessage(LogRecord record, [String? message]) {
    if (kIsWeb) {
      return message ?? record.message;
    }

    final pen = AnsiPen();
    if (record.level >= Level.SHOUT) {
      pen.magenta();
    } else if (record.level >= Level.SEVERE) {
      pen.red();
    } else if (record.level >= Level.WARNING) {
      pen.yellow();
    } else if (record.level >= Level.INFO) {
      pen.blue();
    } else if (record.level >= Level.CONFIG) {
      pen.cyan();
    } else if (record.level >= Level.FINE) {
      pen.green();
    } else if (record.level >= Level.FINER) {
      pen.white();
    } else {
      pen.gray();
    }
    return pen(message ?? record.message);
  }
}
