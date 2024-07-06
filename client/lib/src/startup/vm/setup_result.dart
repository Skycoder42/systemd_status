import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'setup_result.freezed.dart';

@freezed
sealed class SetupResult with _$SetupResult {
  const factory SetupResult({
    required Uri serverUrl,
    Uint8List? serverCertBytes,
  }) = _SetupResult;
}
