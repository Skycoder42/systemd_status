import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

mixin PlatformServerUrlMixin on AsyncNotifier<Uri?> {
  @protected
  FutureOr<Uri?> loadServerUrl() =>
      throw UnimplementedError('Stub has not been implemented for platform');

  FutureOr<void> saveServerUrl(Uri serverUrl) =>
      throw UnimplementedError('Stub has not been implemented for platform');

  FutureOr<void> clearServerUrl() =>
      throw UnimplementedError('Stub has not been implemented for platform');
}
