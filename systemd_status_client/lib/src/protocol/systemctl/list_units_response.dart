/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import '../protocol.dart' as _i2;

abstract class ListUnitsResponse extends _i1.SerializableEntity {
  ListUnitsResponse._({required this.units});

  factory ListUnitsResponse({required List<_i2.UnitState> units}) =
      _ListUnitsResponseImpl;

  factory ListUnitsResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return ListUnitsResponse(
        units: serializationManager
            .deserialize<List<_i2.UnitState>>(jsonSerialization['units']));
  }

  List<_i2.UnitState> units;

  ListUnitsResponse copyWith({List<_i2.UnitState>? units});
  @override
  Map<String, dynamic> toJson() {
    return {'units': units.toJson(valueToJson: (v) => v.toJson())};
  }
}

class _ListUnitsResponseImpl extends ListUnitsResponse {
  _ListUnitsResponseImpl({required List<_i2.UnitState> units})
      : super._(units: units);

  @override
  ListUnitsResponse copyWith({List<_i2.UnitState>? units}) {
    return ListUnitsResponse(units: units ?? this.units.clone());
  }
}
