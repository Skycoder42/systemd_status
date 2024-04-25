import 'dart:io';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serverpod/server.dart';
import 'package:serverpod/serverpod.dart';

part 'river_serverpod.g.dart';

@Riverpod(keepAlive: true)
Serverpod serverpod(ServerpodRef ref) => throw StateError(
      'serverpodProvider can only be accessed '
      "via RiverServerpod's providerContainer",
    );

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
  Future<void> start({
    List<Override> overrides = const [],
    List<ProviderObserver>? observers,
  }) {
    providerContainer = ProviderContainer(
      overrides: [
        serverpodProvider.overrideWithValue(this),
        ...overrides,
      ],
      observers: observers,
    );
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
