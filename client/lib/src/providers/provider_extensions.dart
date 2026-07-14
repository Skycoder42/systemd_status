import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

typedef Selector<TI, TR> = TR Function(TI value);

extension FutureProviderExtensions<T> on ProviderListenable<AsyncValue<T>> {
  ProviderListenable<TReturn> selectData<TReturn>(
    Selector<T, TReturn> selector,
  ) => select(
    (asyncValue) => switch (asyncValue) {
      AsyncData(:final T value) => selector(value),
      _ => throw StateError('$this has not been initialized!'),
    },
  );
}
