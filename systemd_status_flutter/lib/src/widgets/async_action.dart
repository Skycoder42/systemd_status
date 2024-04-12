import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'error_snack_bar.dart';

typedef ActionBuilder = Widget Function(VoidCallback? onAction);

typedef ErrorConverter = String Function(Object error);

class AsyncAction extends StatefulWidget {
  final ActionBuilder builder;
  final bool enabled;
  final AsyncCallback onAction;
  final ErrorConverter onError;

  const AsyncAction({
    super.key,
    this.enabled = true,
    required this.onAction,
    required this.builder,
    this.onError = _AsyncActionState._errorToString,
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
  Future? _pendingAction;

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: _pendingAction,
        builder: (context, snapshot) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (snapshot.isWaiting) ...[
              const CircularProgressIndicator(),
              const SizedBox(width: 8),
            ],
            widget.builder(
              !widget.enabled || snapshot.isWaiting ? null : _onAction,
            ),
          ],
        ),
      );

  void _onAction() {
    // ignore: discarded_futures
    final result = widget.onAction().catchError(_onError);
    setState(() {
      _pendingAction = result;
    });
  }

  void _onError(Object error, StackTrace stackTrace) {
    Zone.current.handleUncaughtError(error, stackTrace); // TODO handle better
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      ErrorSnackBar(
        context: context,
        content: Text(widget.onError(error)),
      ),
    );
  }

  static String _errorToString(Object error) => error.toString();
}

extension on AsyncSnapshot {
  bool get isWaiting => connectionState == ConnectionState.waiting;
}
