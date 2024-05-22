import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';

@freezed
sealed class Settings with _$Settings {
  const factory Settings({
    required Uri serverUrl,
    required String firebaseApiKey,
    String? sentryDsn,
  }) = _Settings;
}
