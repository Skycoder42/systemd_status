import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_permissions.freezed.dart';
part 'user_permissions.g.dart';

@freezed
sealed class UserPermissions with _$UserPermissions {
  const factory({required bool canReboot}) = _UserPermissions;

  factory fromJson(Map<String, dynamic> json) =>
      _$UserPermissionsFromJson(json);
}
