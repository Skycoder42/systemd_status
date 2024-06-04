import 'package:shelf_api/shelf_api.dart';

import '../../config/server_config.dart';
import '../models/client_config.dart';

@ApiEndpoint('/config')
class ConfigEndpoint extends ShelfEndpoint {
  ConfigEndpoint(super.request);

  @Get('/')
  TResponse<ClientConfig> get() {
    final config = ref.read(serverConfigProvider);
    return TResponse.ok(
      ClientConfig(
        firebaseApiKey: config.firebase.apiKey,
        sentryDsn: config.app.sentryDsn,
      ),
    );
  }
}
