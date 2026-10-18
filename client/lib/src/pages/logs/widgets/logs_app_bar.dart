import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:systemd_status_server/api.dart';

import '../../../app/router.dart';
import '../../../localization/localization.dart';
import '../../../widgets/content_app_bar.dart';
import 'log_priority_extensions.dart';

class const LogsAppBar({
  super.key,
  required final String unitName,
  required final LogPriority? logPriority,
  required final ValueChanged<LogPriority?> onLogPriorityChanged,
  required final VoidCallback onRefresh,
}) extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => ContentAppBar.defaultSize;

  @override
  Widget build(BuildContext context) => ContentAppBar(
    title: context.strings.logs_page_title(unitName),
    onRefresh: onRefresh,
    menuItems: [
      SubmenuButton(
        menuChildren: [
          for (final priority in LogPriority.values)
            RadioMenuButton<LogPriority>(
              value: priority,
              groupValue: logPriority,
              onChanged: onLogPriorityChanged,
              child: Text(
                context.strings.log_priority(priority.name),
                style: priority.style,
              ),
            ),
        ],
        child: Text(context.strings.logs_page_priority_button),
      ),
      MenuItemButton(
        onPressed: () async => await _restart(context),
        child: Text(context.strings.restart_dialog_restart_button),
      ),
    ],
  );

  Future<void> _restart(BuildContext context) async {
    final needsReload = await RestartUnitRoute(unitName).push<bool>(context);
    if (needsReload ?? false) {
      onRefresh();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('unitName', unitName))
      ..add(EnumProperty<LogPriority?>('logPriority', logPriority))
      ..add(
        ObjectFlagProperty<ValueChanged<LogPriority?>>.has(
          'onLogPriorityChanged',
          onLogPriorityChanged,
        ),
      )
      ..add(ObjectFlagProperty<VoidCallback>.has('onRefresh', onRefresh));
  }
}
