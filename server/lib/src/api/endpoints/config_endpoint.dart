import 'package:shelf_api/shelf_api.dart';

import '../../config/server_config.dart';
import '../models/client_config.dart';

@ApiEndpoint('/config')
class ConfigEndpoint extends ShelfEndpoint {
  ConfigEndpoint(super.request);

  @Get('/')
  TResponse<ClientConfig> get() {
    final appConfig = ref.read(serverConfigProvider).appConfig;
    return TResponse.ok(
      ClientConfig(
        firebaseApiKey: appConfig.firebaseApiKey,
        sentryDsn: appConfig.sentryDsn,
      ),
    );
  }
}
