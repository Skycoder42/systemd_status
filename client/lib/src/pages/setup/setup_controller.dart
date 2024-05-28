import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/config/app_settings.dart';
import '../../app/router.dart';

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
  SetupState build() => SetupState(
        serverUrl: ref.read(settingsServerUrlProvider),
      );

  Future<void> submit({
    required Uri serverUrl,
    String? redirectTo,
  }) async {
    // persist server url
    _logger.fine('Persisting server url: $serverUrl');
    await persistServerUrl(ref, serverUrl);

    // reload configuration
    _logger.fine('Reloading client configuration');
    try {
      final setupState = await ref.refresh(settingsLoaderProvider.future);
      if (!setupState) {
        throw Exception(
          'Unable to persist server URL. Operation succeeded, '
          'but setup loader still reports setup required.',
        );
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      _logger.warning('Failed refresh app settings', e, s);
      ref.read(routerProvider).go(const ServerUnreachableRoute().location);
      return;
    }

    final redirectTarget = redirectTo ?? const RootRoute().location;
    _logger.config(
      'Server configured, configuration unchanged. '
      'Redirecting to $redirectTarget',
    );
    ref.read(routerProvider).go(redirectTarget);
  }
}
