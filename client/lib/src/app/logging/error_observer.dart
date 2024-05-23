import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry/sentry.dart';

abstract interface class ErrorState {
  Object get error;
  StackTrace get stackTrace;
}

class ErrorObserver extends ProviderObserver {
  const ErrorObserver();

  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    _maybeReportStateException(provider, value);
  }

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    _maybeReportStateException(provider, newValue);
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    reportException(provider, error, stackTrace);
  }

  void _maybeReportStateException(ProviderBase provider, Object? value) {
    switch (value) {
      case ErrorState(error: final error, stackTrace: final stackTrace):
        reportException(provider, error, stackTrace);
    }
  }

  @visibleForOverriding
  void reportException(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
  ) {
    if (Sentry.isEnabled) {
      unawaited(
        Sentry.captureException(
          error,
          stackTrace: stackTrace,
          withScope: (scope) async => Future.wait([
            if (provider.name case final String name)
              scope.setTag('provider', name),
            scope.setContexts('Provider', {
              'identifier': provider.toString(),
              'name': provider.name,
              'providerType': provider.runtimeType.toString(),
              'argument': provider.argument?.toString(),
              'familyTree': _familyTree(provider),
              'dependencies': _toList(provider.dependencies),
              'allTransitiveDependencies':
                  _toList(provider.allTransitiveDependencies),
            }),
          ]),
        ),
      );
    } else {
      final name = provider.name ?? provider.runtimeType.toString();
      Logger('provider.$name')
          .severe('Provider $provider did fail', error, stackTrace);
    }
  }

  List<String>? _familyTree(ProviderOrFamily provider) {
    if (provider.from case final Family from) {
      return [...?_familyTree(from), from.name ?? '<unnamed>'];
    }
    return null;
  }

  List<String?>? _toList(Iterable<ProviderOrFamily>? providers) =>
      providers?.map((p) => p.name).toList();
}
