import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class const HttpClientAdapterFactory() {
  HttpClientAdapter create(Uint8List certBytes) => IOHttpClientAdapter(
    createHttpClient: () => HttpClient(
      context: SecurityContext(withTrustedRoots: true)
        ..setAlpnProtocols(['http/1.1'], false)
        ..setTrustedCertificatesBytes(certBytes),
    ),
  );
}
