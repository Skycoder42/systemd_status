import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../localization/localization.dart';
import 'controllers/action_controller.dart';
import 'error_snack_bar.dart';

class ActionDialog extends ConsumerWidget {
  final ProviderListenable<ActionState> provider;
  final ProviderListenable<ActionController> notifier;
  final String hintTitle;
  final String hint;
  final String actionTitle;
  final String action;
  final String successMessage;
  final String failureMessage;

  const ActionDialog({
    super.key,
    required this.provider,
    required this.notifier,
    required this.hintTitle,
    required this.hint,
    required this.actionTitle,
    required this.action,
    required this.successMessage,
    required this.failureMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(provider, (_, next) {
      switch (next) {
        case .success:
          Navigator.pop<bool>(context, true);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(successMessage)));
        case .failure:
          Navigator.pop<bool>(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            ErrorSnackBar(context: context, content: Text(failureMessage)),
          );
        case _:
          break;
      }
    });

    return switch (ref.watch(provider)) {
      ActionState.hint => AlertDialog(
        title: Text(hintTitle),
        content: Text(hint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop<bool>(context, false),
            child: Text(context.strings.cancel),
          ),
          TextButton(
            onPressed: () async => await ref.read(notifier)(),
            child: Text(action),
          ),
        ],
      ),
      _ => AlertDialog(
        title: Text(actionTitle),
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
    properties
      ..add(
        DiagnosticsProperty<ProviderListenable<ActionState>>(
          'provider',
          provider,
        ),
      )
      ..add(
        DiagnosticsProperty<ProviderListenable<ActionController>>(
          'notifier',
          notifier,
        ),
      )
      ..add(StringProperty('hintTitle', hintTitle))
      ..add(StringProperty('hint', hint))
      ..add(StringProperty('actionTitle', actionTitle))
      ..add(StringProperty('action', action))
      ..add(StringProperty('successMessage', successMessage))
      ..add(StringProperty('failureMessage', failureMessage));
  }
}
