import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../settings.dart';

mixin PlatformAppSettingsMixin on AsyncNotifier<Settings?> {
  @protected
  FutureOr<Settings?> loadSettings() =>
      throw UnimplementedError('Stub has not been implemented for platform');

  FutureOr<bool> updateSettings(Settings settings) =>
      throw UnimplementedError('Stub has not been implemented for platform');

  FutureOr<bool> clearSettings() =>
      throw UnimplementedError('Stub has not been implemented for platform');
}
