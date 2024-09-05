import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localization/localization.dart';
import 'controllers/logout_controller.dart';

class LogoutDialog extends ConsumerStatefulWidget {
  const LogoutDialog({super.key});

  @override
  ConsumerState<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends ConsumerState<LogoutDialog> {
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(context.strings.logout),
        content: switch (ref.watch(logoutControllerProvider)) {
          LogoutState.canLogout =>
            Text(context.strings.logout_dialog_logout_hint),
          LogoutState.canLogoutAndReset => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.strings.logout_dialog_logout_hint),
                Text(context.strings.logout_dialog_reset_hint),
              ],
            ),
          LogoutState.loggingOut => const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
              ],
            ),
        },
        actions: [
          if (ref.watch(logoutControllerProvider) != LogoutState.loggingOut)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.strings.cancel),
            ),
          if (ref.watch(logoutControllerProvider) ==
              LogoutState.canLogoutAndReset)
            TextButton(
              onPressed: () async =>
                  ref.read(logoutControllerProvider.notifier).reset(),
              child: Text(context.strings.reset),
            ),
          if (ref.watch(logoutControllerProvider) != LogoutState.loggingOut)
            TextButton(
              onPressed: () async =>
                  ref.read(logoutControllerProvider.notifier).logOut(),
              child: Text(context.strings.logout),
            ),
        ],
      );
}
