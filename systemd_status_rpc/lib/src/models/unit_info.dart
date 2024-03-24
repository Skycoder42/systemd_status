// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_rpc_codegen/json_rpc_codegen.dart'; // TODO fix this

part 'unit_info.freezed.dart';
part 'unit_info.g.dart';

@freezed
sealed class UnitInfo with _$UnitInfo {
  const factory UnitInfo({
    @JsonKey(name: 'unit') required String name,
    @JsonKey(name: 'load') required String loadState,
    @JsonKey(name: 'active') required String activeState,
    @JsonKey(name: 'sub') required String subState,
    @JsonKey(includeIfNull: false) String? description,
  }) = _UnitInfo;

  factory UnitInfo.fromJson(Map<String, dynamic> json) =>
      _$UnitInfoFromJson(json);
}
