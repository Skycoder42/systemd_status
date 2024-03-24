/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:serverpod_json_rpc_2_client/module.dart' as _i3;
import 'protocol.dart' as _i4;

/// {@category Endpoint}
class EndpointSystemctlBridge extends _i1.EndpointRef {
  EndpointSystemctlBridge(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'systemctlBridge';
}

/// {@category Endpoint}
class EndpointUnits extends _i1.EndpointRef {
  EndpointUnits(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'units';

  _i2.Future<String> listUnitsRaw() => caller.callServerEndpoint<String>(
        'units',
        'listUnitsRaw',
        {},
      );
}

class _Modules {
  _Modules(Client client) {
    rpc = _i3.Caller(client);
  }

  late final _i3.Caller rpc;
}

class Client extends _i1.ServerpodClient {
  Client(
    String host, {
    dynamic securityContext,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
  }) : super(
          host,
          _i4.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
        ) {
    systemctlBridge = EndpointSystemctlBridge(this);
    units = EndpointUnits(this);
    modules = _Modules(this);
  }

  late final EndpointSystemctlBridge systemctlBridge;

  late final EndpointUnits units;

  late final _Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'systemctlBridge': systemctlBridge,
        'units': units,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup =>
      {'rpc': modules.rpc};
}
