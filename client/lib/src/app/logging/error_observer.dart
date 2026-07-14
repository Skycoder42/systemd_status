import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry/sentry.dart';

abstract interface class ErrorState {
  Object get error;
  StackTrace get stackTrace;
}

final class ErrorObserver extends ProviderObserver {
  const ErrorObserver();

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    _maybeReportStateException(context, value);
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    _maybeReportStateException(context, newValue);
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    reportException(context, error, stackTrace);
  }

  void _maybeReportStateException(
    ProviderObserverContext context,
    Object? value,
  ) {
    switch (value) {
      case ErrorState(:final error, :final stackTrace):
        reportException(context, error, stackTrace);
    }
  }

  @visibleForOverriding
  void reportException(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    if (Sentry.isEnabled) {
      unawaited(
        Sentry.captureException(
          error,
          stackTrace: stackTrace,
          withScope: (scope) async => await Future.wait<void>([
            if (context.provider.name case final name?)
              scope.setTag('provider', name),
            Future.sync(
              () => scope.setContexts('Provider', {
                'identifier': context.provider.toString(),
                'name': context.provider.name,
                'providerType': context.provider.runtimeType.toString(),
                'argument': context.provider.argument?.toString(),
                'familyTree': _familyTree(context.provider),
                'dependencies': _toList(context.provider.dependencies),
              }),
            ),
          ]),
        ),
      );
    } else {
      final name =
          context.provider.name ?? context.provider.runtimeType.toString();
      Logger(
        'provider.$name',
      ).severe('Provider ${context.provider} did fail', error, stackTrace);
    }
  }

  List<String>? _familyTree(ProviderOrFamily provider) {
    if (provider.from case final from?) {
      return [...?_familyTree(from), from.name ?? '<unnamed>'];
    }
    return null;
  }

  List<String?>? _toList(Iterable<ProviderOrFamily>? providers) =>
      providers?.map((p) => p.name).toList();
}
