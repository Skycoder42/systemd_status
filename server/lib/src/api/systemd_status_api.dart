import 'package:shelf_api/shelf_api.dart';

import 'endpoints/config_endpoint.dart';
import 'endpoints/units_endpoint.dart';

@ShelfApi(
  basePath: '/api',
  [
    ConfigEndpoint,
    UnitsEndpoint,
  ],
)
// ignore: unused_element
abstract class _SystemdStatusApi {}
