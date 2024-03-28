/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

library protocol; // ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'package:systemd_status_rpc/src/models/unit_info.dart' as _i2;
import 'package:systemd_status_rpc/systemd_status_rpc.dart' as _i3;
import 'package:serverpod_auth_client/module.dart' as _i4;
import 'package:serverpod_json_rpc_2_client/module.dart' as _i5;
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
    if (t == List<_i2.UnitInfo>) {
      return (data as List).map((e) => deserialize<_i2.UnitInfo>(e)).toList()
          as dynamic;
    }
    if (t == _i3.UnitInfo) {
      return _i3.UnitInfo.fromJson(data, this) as T;
    }
    if (t == _i1.getType<_i3.UnitInfo?>()) {
      return (data != null ? _i3.UnitInfo.fromJson(data, this) : null) as T;
    }
    try {
      return _i4.Protocol().deserialize<T>(data, t);
    } catch (_) {}
    try {
      return _i5.Protocol().deserialize<T>(data, t);
    } catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object data) {
    String? className;
    className = _i4.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    className = _i5.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_json_rpc_2.$className';
    }
    if (data is _i3.UnitInfo) {
      return 'UnitInfo';
    }
    return super.getClassNameForObject(data);
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    if (data['className'].startsWith('serverpod_auth.')) {
      data['className'] = data['className'].substring(15);
      return _i4.Protocol().deserializeByClassName(data);
    }
    if (data['className'].startsWith('serverpod_json_rpc_2.')) {
      data['className'] = data['className'].substring(21);
      return _i5.Protocol().deserializeByClassName(data);
    }
    if (data['className'] == 'UnitInfo') {
      return deserialize<_i3.UnitInfo>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
