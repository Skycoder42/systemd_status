import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef Selector<TI, TR> = TR Function(TI value);

extension FutureProviderExtensions<T>
    on AlwaysAliveProviderListenable<AsyncValue<T>> {
  AlwaysAliveProviderListenable<TReturn> selectData<TReturn>(
    Selector<T, TReturn> selector,
  ) =>
      select(
        (asyncValue) => switch (asyncValue) {
          AsyncData(value: final T value) => selector(value),
          _ => throw StateError('$this has not been initialized!'),
        },
      );
}
