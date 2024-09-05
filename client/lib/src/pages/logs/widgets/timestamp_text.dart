import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../localization/localization.dart';

class TimestampText extends StatelessWidget {
  final DateTime timestamp;

  const TimestampText(this.timestamp, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        context.strings.short_date_time(timestamp),
        style: context.theme.textTheme.labelSmall,
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DateTime>('timestamp', timestamp));
  }
}
