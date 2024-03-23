/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../protocol.dart' as _i2;
import 'package:serverpod_serialization/serverpod_serialization.dart';

abstract class ListUnitsResponse extends _i1.SerializableEntity {
  ListUnitsResponse._({
    required this.success,
    required this.units,
  });

  factory ListUnitsResponse({
    required bool success,
    required List<_i2.UnitState> units,
  }) = _ListUnitsResponseImpl;

  factory ListUnitsResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return ListUnitsResponse(
      success:
          serializationManager.deserialize<bool>(jsonSerialization['success']),
      units: serializationManager
          .deserialize<List<_i2.UnitState>>(jsonSerialization['units']),
    );
  }

  bool success;

  List<_i2.UnitState> units;

  ListUnitsResponse copyWith({
    bool? success,
    List<_i2.UnitState>? units,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'units': units.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> allToJson() {
    return {
      'success': success,
      'units': units.toJson(valueToJson: (v) => v.allToJson()),
    };
  }
}

class _ListUnitsResponseImpl extends ListUnitsResponse {
  _ListUnitsResponseImpl({
    required bool success,
    required List<_i2.UnitState> units,
  }) : super._(
          success: success,
          units: units,
        );

  @override
  ListUnitsResponse copyWith({
    bool? success,
    List<_i2.UnitState>? units,
  }) {
    return ListUnitsResponse(
      success: success ?? this.success,
      units: units ?? this.units.clone(),
    );
  }
}
