import 'package:systemd_status_server/api.dart';
import 'package:web/web.dart';

import '../../providers/api_provider.dart';
import '../common/startup_controller.dart';

final class StartupController extends StartupControllerBase {
  static const _serverUrl = bool.hasEnvironment('SERVER_URL')
      ? String.fromEnvironment('SERVER_URL')
      : null;

  @override
  Uri loadServerUrl() => Uri.parse(_serverUrl ?? window.location.origin);

  @override
  Future<ClientConfig> loadClientConfig() async =>
      await container.read(systemdStatusApiClientProvider).configGet();
}
