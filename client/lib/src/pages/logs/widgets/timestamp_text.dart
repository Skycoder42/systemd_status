import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../localization/localization.dart';

class const TimestampText(final DateTime timestamp, {super.key})
    extends StatelessWidget {
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
