import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

enum ActionState { hint, pending, success, failure }

mixin ActionController on AnyNotifier<ActionState, ActionState> {
  @visibleForOverriding
  String get action;

  @visibleForOverriding
  Logger get logger;

  Future<void> execute(CancelToken cancelToken);

  Future<void> call() async {
    try {
      state = ActionState.pending;
      final cancelToken = CancelToken();
      ref.onDispose(cancelToken.cancel);
      await execute(cancelToken);
      state = ActionState.success;
    } on Exception catch (e, s) {
      if (e case DioException(type: DioExceptionType.cancel)) {
        state = ActionState.hint;
        return;
      }

      logger.severe('Failed to $action', e, s);
      state = ActionState.failure;
    }
  }
}
