import 'package:flutter/material.dart';
import 'package:systemd_status_server/api.dart';

extension LogPriorityX on LogPriority {
  FontWeight? get fontWeight => switch (this) {
        LogPriority.emergency => FontWeight.w900,
        LogPriority.alert => FontWeight.w800,
        LogPriority.critical => FontWeight.bold,
        LogPriority.error => FontWeight.bold,
        LogPriority.warning => FontWeight.bold,
        LogPriority.notice => FontWeight.bold,
        _ => null,
      };

  Color? get color => switch (this) {
        LogPriority.emergency => Colors.red.shade900,
        LogPriority.alert => Colors.red.shade800,
        LogPriority.critical => Colors.red.shade700,
        LogPriority.error => Colors.red.shade600,
        LogPriority.warning => Colors.orange,
        LogPriority.notice => null,
        LogPriority.informational => null,
        LogPriority.debug => Colors.grey,
      };
}
