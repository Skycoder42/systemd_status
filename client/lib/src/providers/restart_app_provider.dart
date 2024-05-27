import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:restart_app/restart_app.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'restart_app_provider.g.dart';

@riverpod
Future<bool> restart(RestartRef ref) async {
  final logger = Logger('Restart');
  if (kIsWeb || Platform.isAndroid) {
    logger.fine('Triggering automatic app restart');
    final result = await Restart.restartApp();
    if (!result) {
      logger.warning('Automatic app restart failed!');
    }
    return result;
  } else {
    logger.fine('Automatic app restart is not supported on this device');
    return false;
  }
}
