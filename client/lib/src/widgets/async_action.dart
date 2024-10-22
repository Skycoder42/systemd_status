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
  final Duration? errorToastDuration;

  const AsyncAction({
    super.key,
    this.enabled = true,
    required this.onAction,
    required this.onError,
    required this.builder,
    this.errorToastDuration,
  });

  @override
  State<AsyncAction> createState() => AsyncActionState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ObjectFlagProperty<ActionBuilder>.has('builder', builder))
      ..add(DiagnosticsProperty<bool>('enabled', enabled))
      ..add(ObjectFlagProperty<AsyncCallback>.has('onAction', onAction))
      ..add(ObjectFlagProperty<ErrorConverter?>.has('onError', onError))
      ..add(
        DiagnosticsProperty<Duration?>(
          'errorToastDuration',
          errorToastDuration,
        ),
      );
  }
}

class AsyncActionState extends State<AsyncAction> {
  bool _isRunning = false;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
      _snackbarController;

  bool triggerAction() {
    if (!widget.enabled || _isRunning) {
      return false;
    }

    unawaited(_onAction());
    return true;
  }

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

    _snackbarController?.close();

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

    final controller =
        _snackbarController = ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      ErrorSnackBar(
        context: context,
        content: Text(errorMessage),
        duration: widget.errorToastDuration ?? const Duration(seconds: 4),
      ),
    );
    unawaited(
      controller?.closed.whenComplete(() {
        if (_snackbarController == controller) {
          _snackbarController = null;
        }
      }),
    );
  }
}
