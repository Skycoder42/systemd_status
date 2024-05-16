import 'package:shelf_api/shelf_api.dart';

import 'endpoints/units_endpoint.dart';

@ShelfApi(
  basePath: '/api',
  [UnitsEndpoint],
)
// ignore: unused_element
abstract class _SystemdStatusApi {}
