// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'active_state.dart';
import 'load_state.dart';

part 'unit_info.freezed.dart';
part 'unit_info.g.dart';

@freezed
sealed class UnitInfo with _$UnitInfo {
  const factory UnitInfo({
    @JsonKey(name: 'unit') required String name,
    @JsonKey(name: 'load') required LoadState loadState,
    @JsonKey(name: 'active') required ActiveState activeState,
    @JsonKey(name: 'sub') required String subState,
    @JsonKey(includeIfNull: false) String? description,
  }) = _UnitInfo;

  factory UnitInfo.fromJson(Map<String, dynamic> json) =>
      _$UnitInfoFromJson(json);

  static List<UnitInfo> fromJsonList(List<dynamic> json) =>
      json.cast<Map<String, dynamic>>().map(UnitInfo.fromJson).toList();
}
