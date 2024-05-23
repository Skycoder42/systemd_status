import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/router.dart';
import '../../settings/server_url.dart';
import '../../settings/setup_loader.dart';

part 'setup_controller.freezed.dart';
part 'setup_controller.g.dart';

@freezed
sealed class SetupState with _$SetupState {
  const factory SetupState({
    required Uri? serverUrl,
  }) = _SetupState;

  const SetupState._();

  String get urlInput => serverUrl?.toString() ?? 'https://';
}

@riverpod
class SetupController extends _$SetupController {
  final _logger = Logger('SetupController');

  @override
  Future<SetupState> build() async {
    final serverUrl = await ref.read(serverUrlProvider.future);
    _logger.fine('Loaded server url from storage: $serverUrl');
    return SetupState(serverUrl: serverUrl);
  }

  Future<void> submit({
    required Uri serverUrl,
    String? redirectTo,
  }) async {
    // persist server url
    _logger.fine('Persisting server url: $serverUrl');
    await update((state) async {
      final serverUrlNotifier = ref.read(serverUrlProvider.notifier);
      await serverUrlNotifier.saveServerUrl(serverUrl);
      return state.copyWith(serverUrl: serverUrl);
    });

    // reload configuration
    _logger.fine('Reloading client configuration');
    final setupState = await ref.refresh(setupLoaderProvider.future);
    switch (setupState) {
      case SetupRequiredState():
        _logger.severe(
          'Invalid setup loader result: '
          'Should not be required after persisting the serverUrl',
        );
        throw Exception(
          'Unable to persist server URL. Operation succeeded, '
          'but setup loader still reports setup required.',
        );
      case SetupRefreshedState():
        _logger.config(
          'Server configured, configuration changed. '
          'Redirecting to restart page',
        );
        ref.read(routerProvider).go(const RestartAppRoute().location);
      case SetupUnchangedState():
        final redirectTarget = redirectTo ?? const RootRoute().location;
        _logger.config(
          'Server configured, configuration unchanged. '
          'Redirecting to $redirectTarget',
        );
        ref.read(routerProvider).go(redirectTarget);
      case SetupServerUnreachableState():
        _logger.warning('Failed to get client configuration from server');
        ref.read(routerProvider).go(const ServerUnreachableRoute().location);
    }
  }
}
