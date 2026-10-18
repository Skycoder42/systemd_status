import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_config.freezed.dart';
part 'client_config.g.dart';

@freezed
sealed class ClientConfig with _$ClientConfig {
  const factory({required String firebaseApiKey, String? sentryDsn}) =
      _AppConfig;

  factory fromJson(Map<String, dynamic> json) => _$ClientConfigFromJson(json);
}
