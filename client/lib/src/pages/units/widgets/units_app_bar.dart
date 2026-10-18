import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart' hide SuggestionsBuilder;

import '../../../app/auth/permissions_provider.dart';
import '../../../app/router.dart';
import '../../../localization/localization.dart';
import '../../../widgets/content_app_bar.dart';
import 'filter_button.dart';

class const UnitsAppBar({
  super.key,
  required final bool showAll,
  required final ValueChanged<bool?> onToggleShowAll,
  required final VoidCallback onRefresh,
  required final ValueSetter<String> onFilterUpdated,
  required final SuggestionsBuilder suggestionsBuilder,
}) extends ConsumerWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => ContentAppBar.defaultSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ContentAppBar(
    title: context.strings.units_page_title,
    onRefresh: onRefresh,
    actions: [
      FilterButton(
        onFilterUpdated: onFilterUpdated,
        suggestionsBuilder: suggestionsBuilder,
      ),
    ],
    menuItems: [
      CheckboxMenuButton(
        value: showAll,
        onChanged: onToggleShowAll,
        child: Text(context.strings.units_page_display_all_action),
      ),
      if (ref.watch(
        userPermissionsProvider.select((p) => p.value?.canReboot ?? false),
      ))
        MenuItemButton(
          onPressed: () => const RebootRoute().go(context),
          child: Text(context.strings.units_page_reboot_action),
        ),
    ],
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('showAll', showAll))
      ..add(
        ObjectFlagProperty<ValueChanged<bool?>>.has(
          'onToggleShowAll',
          onToggleShowAll,
        ),
      )
      ..add(ObjectFlagProperty<VoidCallback>.has('onRefresh', onRefresh))
      ..add(
        ObjectFlagProperty<ValueSetter<String>>.has(
          'onFilterUpdated',
          onFilterUpdated,
        ),
      )
      ..add(
        ObjectFlagProperty<SuggestionsBuilder>.has(
          'suggestionsBuilder',
          suggestionsBuilder,
        ),
      );
  }
}
