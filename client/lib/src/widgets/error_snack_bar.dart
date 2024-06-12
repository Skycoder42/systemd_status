import 'package:flutter/material.dart';

import '../app/theme.dart';

class ErrorSnackBar extends SnackBar {
  ErrorSnackBar({
    super.key,
    required BuildContext context,
    required Widget content,
    super.duration,
  }) : super(
          backgroundColor: context.theme.colorScheme.error,
          content: DefaultTextStyle(
            style: TextStyle(
              color: context.theme.colorScheme.onError,
            ),
            child: content,
          ),
        );
}
