import 'package:material_ui/material_ui.dart';

import '../app/theme.dart';

// ignore: prefer_const_constructors_in_immutables false positive, initializer depends on context
class ErrorSnackBar({
  super.key,
  required BuildContext context,
  required Widget content,
  super.duration,
}) extends SnackBar {
  this
    : super(
        backgroundColor: context.theme.colorScheme.error,
        content: DefaultTextStyle(
          style: TextStyle(color: context.theme.colorScheme.onError),
          child: content,
        ),
      );
}
