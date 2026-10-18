import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart' hide SuggestionsBuilder;

import '../app/router.dart';
import '../extensions/flutter_x.dart';
import '../localization/localization.dart';

class const ContentAppBar({
  super.key,
  required final String title,
  final VoidCallback? onRefresh,
  final List<Widget> actions = const [],
  final List<Widget> menuItems = const [],
}) extends StatelessWidget implements PreferredSizeWidget {
  static const defaultSize = Size.fromHeight(kToolbarHeight);

  @override
  Size get preferredSize => defaultSize;

  @override
  Widget build(BuildContext context) => AppBar(
    title: Text(title),
    actions: [
      ...actions,
      if (onRefresh != null && defaultTargetPlatform.isDesktop)
        IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh)),
      MenuAnchor(
        menuChildren: [
          ...menuItems,
          const Divider(),
          MenuItemButton(
            onPressed: () async => await const LogoutRoute().push(context),
            child: Text(context.strings.logout),
          ),
        ],
        builder: (context, controller, child) => IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.more_vert),
        ),
      ),
    ],
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('title', title))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onRefresh', onRefresh));
  }
}
