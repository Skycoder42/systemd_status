import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serverpod/serverpod.dart';

import 'river_serverpod.dart';

part 'session_ref.g.dart';

@Riverpod(keepAlive: true, dependencies: [])
Session activeSession(ActiveSessionRef ref) =>
    throw StateError('sessionProvider can only be accessed via session.ref');

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
  SessionRef get ref => SessionRef(
        _ProviderContainerWrapper.forSession(this).container,
        this,
      );

  ProviderContainer get _rootContainer => switch (this.serverpod) {
        RiverServerpod(providerContainer: final container) => container,
        _ => throw StateError(
            'Cannot use session.ref if '
            'the associated serverpod is not a RiverServerpod. '
            '(Actual instance type: ${this.serverpod.runtimeType})',
          ),
      };
}

class _ProviderContainerWrapper {
  static final _sessionContainers = Expando<_ProviderContainerWrapper>(
    'SessionRef.sessionContainers',
  );

  static final _finalizer = Finalizer<ProviderContainer>(
    (container) => container.dispose(),
  );

  final ProviderContainer container;

  _ProviderContainerWrapper(this.container) {
    _finalizer.attach(this, container);
  }

  factory _ProviderContainerWrapper.forSession(Session session) {
    final weakSession = WeakReference(session);
    return _sessionContainers[session] ??= _ProviderContainerWrapper(
      ProviderContainer(
        parent: session._rootContainer,
        overrides: [
          activeSessionProvider.overrideWith((ref) => weakSession.target!),
        ],
      ),
    );
  }
}
