import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

extension FlutterSecureStorageX on FlutterSecureStorage {
  Future<Uint8List?> readBytes({required String key}) async {
    final encodedData = await read(key: key);
    if (encodedData == null) {
      return null;
    }
    return base64.decode(encodedData);
  }

  Future<void> writeBytes({
    required String key,
    required List<int> value,
  }) async {
    final encodedData = base64.encode(value);
    await write(key: key, value: encodedData);
  }
}
