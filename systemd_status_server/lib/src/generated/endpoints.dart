/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../endpoints/systemctl_bridge_endpoint.dart' as _i2;
import 'package:serverpod_json_rpc_2_server/module.dart' as _i3;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'systemctlBridge': _i2.SystemctlBridgeEndpoint()
        ..initialize(
          server,
          'systemctlBridge',
          null,
        )
    };
    connectors['systemctlBridge'] = _i1.EndpointConnector(
      name: 'systemctlBridge',
      endpoint: endpoints['systemctlBridge']!,
      methodConnectors: {},
    );
    modules['serverpod_json_rpc_2'] = _i3.Endpoints()
      ..initializeEndpoints(server);
  }
}
