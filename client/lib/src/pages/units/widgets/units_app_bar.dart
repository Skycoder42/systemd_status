import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide SuggestionsBuilder;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router.dart';
import '../../../extensions/flutter_x.dart';
import '../../../localization/localization.dart';
import 'filter_button.dart';

class UnitsAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool showAll;
  final VoidCallback onToggleShowAll;
  final VoidCallback onRefresh;
  final ValueSetter<String> onFilterUpdated;
  final SuggestionsBuilder suggestionsBuilder;

  const UnitsAppBar({
    super.key,
    required this.showAll,
    required this.onToggleShowAll,
    required this.onRefresh,
    required this.onFilterUpdated,
    required this.suggestionsBuilder,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppBar(
        title: Text(context.strings.units_page_title),
        actions: [
          FilterButton(
            onFilterUpdated: onFilterUpdated,
            suggestionsBuilder: suggestionsBuilder,
          ),
          PopupMenuButton(
            itemBuilder: (context) => <PopupMenuEntry>[
              CheckedPopupMenuItem(
                checked: showAll,
                onTap: onToggleShowAll,
                child: Text(
                  context.strings.units_page_display_all_action,
                ),
              ),
              if (defaultTargetPlatform.isDesktop)
                PopupMenuItem(
                  onTap: onRefresh,
                  child: Text(
                    context.strings.units_page_reload_action,
                  ),
                ),
              const PopupMenuDivider(),
              PopupMenuItem(
                onTap: () async => const LogoutRoute().push(context),
                child: Text(
                  context.strings.logout,
                ),
              ),
            ],
          ),
        ],
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('showAll', showAll))
      ..add(
        ObjectFlagProperty<VoidCallback>.has(
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
