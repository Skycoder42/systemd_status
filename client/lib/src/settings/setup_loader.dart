import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/client_provider.dart';
import 'client_config.dart';
import 'server_url.dart';

part 'setup_loader.freezed.dart';
part 'setup_loader.g.dart';

@freezed
sealed class SetupState with _$SetupState {
  const factory SetupState.required({@Default(false) bool withError}) =
      SetupRequiredState;
  const factory SetupState.refreshed() = SetupRefreshedState;
  const factory SetupState.unchanged() = SetupUnchangedState;
  const factory SetupState.serverUnreachable({
    required String errorMessage,
    int? statusCode,
  }) = SetupServerUnreachableState;
}

@riverpod
SetupState setupState(SetupStateRef ref) =>
    switch (ref.watch(setupLoaderProvider)) {
      AsyncData(value: final value) => value,
      AsyncError() => const SetupState.required(withError: true),
      _ => throw StateError('setupLoaderProvider has not been initialized!'),
    };

@Riverpod(keepAlive: true)
class SetupLoader extends _$SetupLoader {
  final _logger = Logger('SetupLoader');

  @override
  Future<SetupState> build() async {
    _logger.finer('Checking if server URL is set');
    final serverUrl = await ref.watch(serverUrlProvider.future);
    if (serverUrl == null) {
      _logger.fine('Server URL is not set. Entering required state.');
      return const SetupState.required();
    }

    try {
      _logger.finer('Loading local configuration');
      final localConfig = await ref.watch(clientConfigLoaderProvider.future);
      _logger.finer('Loading server configuration');
      final remoteConfig =
          await ref.watch(systemdStatusApiClientProvider).configGet();

      _logger.finer('Compare local with server configuration');
      if (localConfig != remoteConfig) {
        _logger.fine(
          'Client configuration has been updated. '
          'Persisting changes and entering refreshed state.',
        );
        await ref
            .read(clientConfigLoaderProvider.notifier)
            .updateConfig(remoteConfig);
        return const SetupState.refreshed();
      }

      _logger.fine(
        'Client configuration is up to date. Entering unchanged state',
      );
      return const SetupState.unchanged();
    } on DioException catch (e, s) {
      _logger.warning(
        'Failed to load config from server. Entering serverUnreachable state',
        e,
        s,
      );
      return SetupState.serverUnreachable(
        errorMessage: e.toString(),
        statusCode: e.response?.statusCode,
      );
    }
  }
}
