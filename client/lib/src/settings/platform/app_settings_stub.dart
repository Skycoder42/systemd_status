import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../settings.dart';

mixin PlatformAppSettingsMixin {
  @protected
  Settings loadSettings() =>
      throw UnimplementedError('Stub has not been implemented for platform');

  FutureOr<bool> setServerUrl(Uri serverUrl) =>
      throw UnimplementedError('Stub has not been implemented for platform');

  FutureOr<bool> removeServerUrl() =>
      throw UnimplementedError('Stub has not been implemented for platform');

  FutureOr<bool> setGoogleAuthSettings(GoogleAuthSettings googleAuthSettings) =>
      throw UnimplementedError('Stub has not been implemented for platform');

  FutureOr<bool> removeGoogleAuthSettings() =>
      throw UnimplementedError('Stub has not been implemented for platform');
}
