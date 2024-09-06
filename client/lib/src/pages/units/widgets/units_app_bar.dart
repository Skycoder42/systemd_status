import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide SuggestionsBuilder;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../localization/localization.dart';
import '../../../widgets/content_app_bar.dart';
import 'filter_button.dart';

class UnitsAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool showAll;
  final ValueChanged<bool?> onToggleShowAll;
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
