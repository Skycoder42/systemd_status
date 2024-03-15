/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

library protocol; // ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'example.dart' as _i2;
import 'systemctl/list_units_response.dart' as _i3;
import 'systemctl/systemctl_command.dart' as _i4;
import 'systemctl/unit_state.dart' as _i5;
import 'protocol.dart' as _i6;
export 'example.dart';
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
    if (t == _i2.Example) {
      return _i2.Example.fromJson(data, this) as T;
    }
    if (t == _i3.ListUnitsResponse) {
      return _i3.ListUnitsResponse.fromJson(data, this) as T;
    }
    if (t == _i4.SystemctlCommand) {
      return _i4.SystemctlCommand.fromJson(data) as T;
    }
    if (t == _i5.UnitState) {
      return _i5.UnitState.fromJson(data, this) as T;
    }
    if (t == _i1.getType<_i2.Example?>()) {
      return (data != null ? _i2.Example.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i3.ListUnitsResponse?>()) {
      return (data != null ? _i3.ListUnitsResponse.fromJson(data, this) : null)
          as T;
    }
    if (t == _i1.getType<_i4.SystemctlCommand?>()) {
      return (data != null ? _i4.SystemctlCommand.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.UnitState?>()) {
      return (data != null ? _i5.UnitState.fromJson(data, this) : null) as T;
    }
    if (t == List<_i6.UnitState>) {
      return (data as List).map((e) => deserialize<_i6.UnitState>(e)).toList()
          as dynamic;
    }
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object data) {
    if (data is _i2.Example) {
      return 'Example';
    }
    if (data is _i3.ListUnitsResponse) {
      return 'ListUnitsResponse';
    }
    if (data is _i4.SystemctlCommand) {
      return 'SystemctlCommand';
    }
    if (data is _i5.UnitState) {
      return 'UnitState';
    }
    return super.getClassNameForObject(data);
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    if (data['className'] == 'Example') {
      return deserialize<_i2.Example>(data['data']);
    }
    if (data['className'] == 'ListUnitsResponse') {
      return deserialize<_i3.ListUnitsResponse>(data['data']);
    }
    if (data['className'] == 'SystemctlCommand') {
      return deserialize<_i4.SystemctlCommand>(data['data']);
    }
    if (data['className'] == 'UnitState') {
      return deserialize<_i5.UnitState>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
