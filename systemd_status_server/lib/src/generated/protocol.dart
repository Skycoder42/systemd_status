/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

library protocol; // ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod/serverpod.dart' as _i1;
import 'package:serverpod/protocol.dart' as _i2;
import 'example.dart' as _i3;
import 'systemctl/list_units_response.dart' as _i4;
import 'systemctl/systemctl_command.dart' as _i5;
import 'systemctl/unit_state.dart' as _i6;
import 'protocol.dart' as _i7;
export 'example.dart';
export 'systemctl/list_units_response.dart';
export 'systemctl/systemctl_command.dart';
export 'systemctl/unit_state.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Map<Type, _i1.constructor> customConstructors = {};

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    ..._i2.Protocol.targetTableDefinitions
  ];

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (customConstructors.containsKey(t)) {
      return customConstructors[t]!(data, this) as T;
    }
    if (t == _i3.Example) {
      return _i3.Example.fromJson(data, this) as T;
    }
    if (t == _i4.ListUnitsResponse) {
      return _i4.ListUnitsResponse.fromJson(data, this) as T;
    }
    if (t == _i5.SystemctlCommand) {
      return _i5.SystemctlCommand.fromJson(data) as T;
    }
    if (t == _i6.UnitState) {
      return _i6.UnitState.fromJson(data, this) as T;
    }
    if (t == _i1.getType<_i3.Example?>()) {
      return (data != null ? _i3.Example.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i4.ListUnitsResponse?>()) {
      return (data != null ? _i4.ListUnitsResponse.fromJson(data, this) : null)
          as T;
    }
    if (t == _i1.getType<_i5.SystemctlCommand?>()) {
      return (data != null ? _i5.SystemctlCommand.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.UnitState?>()) {
      return (data != null ? _i6.UnitState.fromJson(data, this) : null) as T;
    }
    if (t == List<_i7.UnitState>) {
      return (data as List).map((e) => deserialize<_i7.UnitState>(e)).toList()
          as dynamic;
    }
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object data) {
    if (data is _i3.Example) {
      return 'Example';
    }
    if (data is _i4.ListUnitsResponse) {
      return 'ListUnitsResponse';
    }
    if (data is _i5.SystemctlCommand) {
      return 'SystemctlCommand';
    }
    if (data is _i6.UnitState) {
      return 'UnitState';
    }
    return super.getClassNameForObject(data);
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    if (data['className'] == 'Example') {
      return deserialize<_i3.Example>(data['data']);
    }
    if (data['className'] == 'ListUnitsResponse') {
      return deserialize<_i4.ListUnitsResponse>(data['data']);
    }
    if (data['className'] == 'SystemctlCommand') {
      return deserialize<_i5.SystemctlCommand>(data['data']);
    }
    if (data['className'] == 'UnitState') {
      return deserialize<_i6.UnitState>(data['data']);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'systemd_status';
}
