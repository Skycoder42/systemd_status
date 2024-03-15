/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class UnitState extends _i1.SerializableEntity {
  UnitState._({
    required this.unit,
    required this.load,
    required this.active,
    required this.sub,
    this.description,
  });

  factory UnitState({
    required String unit,
    required String load,
    required String active,
    required String sub,
    String? description,
  }) = _UnitStateImpl;

  factory UnitState.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return UnitState(
      unit: serializationManager.deserialize<String>(jsonSerialization['unit']),
      load: serializationManager.deserialize<String>(jsonSerialization['load']),
      active:
          serializationManager.deserialize<String>(jsonSerialization['active']),
      sub: serializationManager.deserialize<String>(jsonSerialization['sub']),
      description: serializationManager
          .deserialize<String?>(jsonSerialization['description']),
    );
  }

  String unit;

  String load;

  String active;

  String sub;

  String? description;

  UnitState copyWith({
    String? unit,
    String? load,
    String? active,
    String? sub,
    String? description,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'unit': unit,
      'load': load,
      'active': active,
      'sub': sub,
      if (description != null) 'description': description,
    };
  }

  @override
  Map<String, dynamic> allToJson() {
    return {
      'unit': unit,
      'load': load,
      'active': active,
      'sub': sub,
      if (description != null) 'description': description,
    };
  }
}

class _Undefined {}

class _UnitStateImpl extends UnitState {
  _UnitStateImpl({
    required String unit,
    required String load,
    required String active,
    required String sub,
    String? description,
  }) : super._(
          unit: unit,
          load: load,
          active: active,
          sub: sub,
          description: description,
        );

  @override
  UnitState copyWith({
    String? unit,
    String? load,
    String? active,
    String? sub,
    Object? description = _Undefined,
  }) {
    return UnitState(
      unit: unit ?? this.unit,
      load: load ?? this.load,
      active: active ?? this.active,
      sub: sub ?? this.sub,
      description: description is String? ? description : this.description,
    );
  }
}
