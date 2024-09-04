import 'package:shelf_api/shelf_api.dart';

import '../../config/server_config.dart';
import '../models/client_config.dart';

@ApiEndpoint('/config')
class ConfigEndpoint extends ShelfEndpoint {
  ConfigEndpoint(super.request);

  @Get('/')
  ClientConfig get() {
    final config = ref.read(serverConfigProvider);
    return ClientConfig(
      firebaseApiKey: config.firebase.apiKey,
      sentryDsn: config.app.sentryDsn,
    );
  }
}
