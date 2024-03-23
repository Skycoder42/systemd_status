import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:serverpod/serverpod.dart';

import 'river_serverpod.dart';

class SessionRef {
  final ProviderContainer _container;

  final Session session;

  SessionRef(this._container, this.session);

  bool exists(ProviderBase<Object?> provider) => _container.exists(provider);

  ProviderSubscription<T> listen<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
  }) =>
      _container.listen(
        provider,
        listener,
        onError: onError,
        fireImmediately: fireImmediately,
      );

  T read<T>(ProviderListenable<T> provider) => _container.read(provider);

  @useResult
  State refresh<State>(Refreshable<State> provider) =>
      _container.refresh(provider);

  void invalidate(ProviderOrFamily provider) => _container.invalidate(provider);
}

extension SessionX on Session {
  SessionRef get ref => SessionRef(_container, this);

  ProviderContainer get _container => switch (serverpod) {
        RiverServerpod(providerContainer: final container) => container,
        _ => throw StateError(
            'Cannot use session.ref if '
            'the associated serverpod is not a RiverServerpod. '
            '(Actual instance type: ${serverpod.runtimeType})',
          ),
      };
}
