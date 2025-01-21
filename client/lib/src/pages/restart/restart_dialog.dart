import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localization/localization.dart';
import '../../widgets/error_snack_bar.dart';
import 'controller/restart_controller.dart';

class RestartDialog extends ConsumerWidget {
  final String unit;

  const RestartDialog({
    super.key,
    required this.unit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      restartControllerProvider(unit),
      (_, next) {
        switch (next) {
          case RestartState.success:
            Navigator.pop<bool>(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.strings.restart_dialog_success_message),
              ),
            );
          case RestartState.failure:
            Navigator.pop<bool>(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                context: context,
                content:
                    Text(context.strings.restart_dialog_failed_message(unit)),
              ),
            );
          // ignore: no_default_cases
          default:
            break;
        }
      },
    );

    return switch (ref.watch(restartControllerProvider(unit))) {
      RestartState.hint => AlertDialog(
          title: Text(context.strings.restart_dialog_hint_title(unit)),
          content: Text(context.strings.restart_dialog_hint_text),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop<bool>(context, false),
              child: Text(context.strings.cancel),
            ),
            TextButton(
              onPressed: () async => await ref
                  .read(restartControllerProvider(unit).notifier)
                  .restart(),
              child: Text(context.strings.restart_dialog_restart_button),
            ),
          ],
        ),
      _ => AlertDialog(
          title: Text(context.strings.restart_dialog_pending_title(unit)),
          content: const LinearProgressIndicator(),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop<bool>(context, true),
              child: Text(context.strings.cancel),
            ),
          ],
        ),
    };
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('unit', unit));
  }
}
