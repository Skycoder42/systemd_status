import 'dart:io';

import 'package:riverpod/riverpod.dart';
import 'package:serverpod/serverpod.dart';

class RiverServerpod extends Serverpod {
  late ProviderContainer providerContainer;

  RiverServerpod(
    super.args,
    super.serializationManager,
    super.endpoints, {
    super.authenticationHandler,
    super.healthCheckHandler,
    super.httpResponseHeaders,
    super.httpOptionsResponseHeaders,
  });

  @override
  Future<void> start([ProviderContainer? container]) {
    providerContainer = container ?? ProviderContainer();
    return super.start();
  }

  @override
  Future<void> shutdown({bool exitProcess = true}) async {
    await super.shutdown(exitProcess: false);
    providerContainer.dispose();
    if (exitProcess) {
      exit(0);
    }
  }
}
