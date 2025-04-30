import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localization/localization.dart';
import '../../widgets/action_dialog.dart';
import 'controllers/reboot_controller.dart';

class RebootDialog extends ConsumerWidget {
  const RebootDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ActionDialog(
    provider: rebootControllerProvider,
    notifier: rebootControllerProvider.notifier,
    hintTitle: context.strings.reboot_dialog_hint_title,
    hint: context.strings.reboot_dialog_hint,
    actionTitle: context.strings.reboot_dialog_action_title,
    action: context.strings.reboot_dialog_action_button,
    successMessage: context.strings.reboot_dialog_success_message,
    failureMessage: context.strings.reboot_dialog_failed_message,
  );
}
