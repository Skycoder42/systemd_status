import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localization/localization.dart';
import '../../widgets/action_dialog.dart';
import 'controllers/restart_controller.dart';

class RestartDialog extends ConsumerWidget {
  final String unit;

  const RestartDialog({super.key, required this.unit});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ActionDialog(
    provider: restartControllerProvider(unit),
    notifier: restartControllerProvider(unit).notifier,
    hintTitle: context.strings.restart_dialog_hint_title(unit),
    hint: context.strings.restart_dialog_hint_text,
    actionTitle: context.strings.restart_dialog_pending_title(unit),
    action: context.strings.restart_dialog_restart_button,
    successMessage: context.strings.restart_dialog_success_message,
    failureMessage: context.strings.restart_dialog_failed_message(unit),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('unit', unit));
  }
}
