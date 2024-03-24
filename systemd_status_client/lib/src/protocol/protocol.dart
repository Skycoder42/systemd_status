/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

library protocol; // ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'systemctl/list_units_response.dart' as _i2;
import 'systemctl/systemctl_command.dart' as _i3;
import 'systemctl/unit_state.dart' as _i4;
import 'protocol.dart' as _i5;
import 'package:serverpod_json_rpc_2_client/module.dart' as _i6;
export 'systemctl/list_units_response.dart';
export 'systemctl/systemctl_command.dart';
export 'systemctl/unit_state.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Map<Type, _i1.constructor> customConstructors = {};

  static final Protocol _instance = Protocol._();

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (customConstructors.containsKey(t)) {
      return customConstructors[t]!(data, this) as T;
    }
    if (t == _i2.ListUnitsResponse) {
      return _i2.ListUnitsResponse.fromJson(data, this) as T;
    }
    if (t == _i3.SystemctlCommand) {
      return _i3.SystemctlCommand.fromJson(data) as T;
    }
    if (t == _i4.UnitState) {
      return _i4.UnitState.fromJson(data, this) as T;
    }
    if (t == _i1.getType<_i2.ListUnitsResponse?>()) {
      return (data != null ? _i2.ListUnitsResponse.fromJson(data, this) : null)
          as T;
    }
    if (t == _i1.getType<_i3.SystemctlCommand?>()) {
      return (data != null ? _i3.SystemctlCommand.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.UnitState?>()) {
      return (data != null ? _i4.UnitState.fromJson(data, this) : null) as T;
    }
    if (t == List<_i5.UnitState>) {
      return (data as List).map((e) => deserialize<_i5.UnitState>(e)).toList()
          as dynamic;
    }
    try {
      return _i6.Protocol().deserialize<T>(data, t);
    } catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object data) {
    String? className;
    className = _i6.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_json_rpc_2.$className';
    }
    if (data is _i2.ListUnitsResponse) {
      return 'ListUnitsResponse';
    }
    if (data is _i3.SystemctlCommand) {
      return 'SystemctlCommand';
    }
    if (data is _i4.UnitState) {
      return 'UnitState';
    }
    return super.getClassNameForObject(data);
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    if (data['className'].startsWith('serverpod_json_rpc_2.')) {
      data['className'] = data['className'].substring(21);
      return _i6.Protocol().deserializeByClassName(data);
    }
    if (data['className'] == 'ListUnitsResponse') {
      return deserialize<_i2.ListUnitsResponse>(data['data']);
    }
    if (data['className'] == 'SystemctlCommand') {
      return deserialize<_i3.SystemctlCommand>(data['data']);
    }
    if (data['className'] == 'UnitState') {
      return deserialize<_i4.UnitState>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
