import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'error_snack_bar.dart';

typedef ActionBuilder = Widget Function(VoidCallback? onAction);

typedef ErrorConverter = String? Function(Object error, StackTrace stackTrace);

class AsyncAction extends StatefulWidget {
  final ActionBuilder builder;
  final bool enabled;
  final AsyncCallback onAction;
  final ErrorConverter onError;

  const AsyncAction({
    super.key,
    this.enabled = true,
    required this.onAction,
    required this.onError,
    required this.builder,
  });

  @override
  State<AsyncAction> createState() => _AsyncActionState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ObjectFlagProperty<ActionBuilder>.has('builder', builder))
      ..add(DiagnosticsProperty<bool>('enabled', enabled))
      ..add(ObjectFlagProperty<AsyncCallback>.has('onAction', onAction))
      ..add(ObjectFlagProperty<ErrorConverter?>.has('onError', onError));
  }
}

class _AsyncActionState extends State<AsyncAction> {
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isRunning) ...[
            const CircularProgressIndicator(),
            const SizedBox(width: 8),
          ],
          widget.builder(
            !widget.enabled || _isRunning ? null : _onAction,
          ),
        ],
      );

  Future<void> _onAction() async {
    setState(() {
      _isRunning = true;
    });
    try {
      await widget.onAction();
      // ignore: avoid_catches_without_on_clauses
    } catch (error, stackTrace) {
      _onError(error, stackTrace);
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _onError(Object error, StackTrace stackTrace) {
    final errorMessage = widget.onError(error, stackTrace);
    if (errorMessage == null) {
      return;
    }

    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      ErrorSnackBar(
        context: context,
        content: Text(errorMessage),
      ),
    );
  }
}
