import 'package:flutter/material.dart';
import 'package:systemd_status_server/api.dart';

extension LogPriorityX on LogPriority {
  Color? get color => switch (this) {
        LogPriority.emergency => Colors.red.shade900,
        LogPriority.alert => Colors.red.shade800,
        LogPriority.critical => Colors.red.shade700,
        LogPriority.error => Colors.red.shade600,
        LogPriority.warning => Colors.yellow,
        LogPriority.notice => Colors.lightBlue,
        LogPriority.informational => null,
        LogPriority.debug => Colors.grey,
      };
}
