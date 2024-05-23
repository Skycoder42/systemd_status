import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'platform/server_url_stub.dart'
    if (dart.library.html) 'platform/server_url_web.dart'
    if (dart.library.io) 'platform/server_url_vm.dart';

part 'server_url.g.dart';

@Riverpod(keepAlive: true)
class ServerUrl extends _$ServerUrl with PlatformServerUrlMixin {
  @override
  Future<Uri?> build() async => await loadServerUrl();
}
