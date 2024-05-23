import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_snack_bar.dart';

typedef ErrorToString = String Function(Object error);

extension ErrorListener on WidgetRef {
  void listenForErrors<T>(
    BuildContext context,
    ProviderListenable<AsyncValue<T>> provider, {
    ErrorToString onError = _defaultOnError,
  }) {
    // TODO global logging
    listen(
      provider.select((value) => value.error),
      (_, error) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            ErrorSnackBar(
              context: context,
              content: Text(onError(error)),
            ),
          );
        }
      },
    );
  }

  static String _defaultOnError(Object error) => error.toString();
}
