import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web/web.dart';

import 'server_url_stub.dart' as stub;

mixin PlatformServerUrlMixin on AsyncNotifier<Uri?>
    implements stub.PlatformServerUrlMixin {
  static const _serverUrl = bool.hasEnvironment('SERVER_URL')
      ? String.fromEnvironment('SERVER_URL')
      : null;

  @override
  FutureOr<Uri?> loadServerUrl() =>
      Uri.parse(_serverUrl ?? window.location.origin);

  @override
  FutureOr<void> saveServerUrl(Uri serverUrl) {}

  @override
  FutureOr<void> clearServerUrl() {}
}
