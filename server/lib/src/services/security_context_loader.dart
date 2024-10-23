import 'dart:io';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/server_config.dart';

part 'security_context_loader.g.dart';

@riverpod
SecurityContextLoader securityContextLoader(Ref ref) => SecurityContextLoader(
      ref.watch(serverConfigProvider.select((c) => c.tls)),
    );

class SecurityContextLoader {
  final TlsConfig? _tlsConfig;

  SecurityContextLoader(this._tlsConfig);

  Future<SecurityContext?> load() async {
    if (_tlsConfig == null) {
      return null;
    }

    final pfxBytes = await File(_tlsConfig.pfxPath).readAsBytes();
    return SecurityContext()
      ..setAlpnProtocols(['http/1.1'], true)
      ..useCertificateChainBytes(pfxBytes, password: _tlsConfig.pfxPassphrase)
      ..usePrivateKeyBytes(pfxBytes, password: _tlsConfig.pfxPassphrase);
  }
}
