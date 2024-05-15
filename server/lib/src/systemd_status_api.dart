import 'package:shelf_api/shelf_api.dart';

import 'endpoints/units_endpoint.dart';

@ShelfApi(
  basePath: '/api',
  [UnitsEndpoint],
)
abstract class _SystemdStatusApi {}
