import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'riverpod_config.g.dart';

typedef Config = ({
  String keyPath,
});

@Riverpod(keepAlive: true)
class RiverpodConfig extends _$RiverpodConfig {
  @override
  Config build() => throw StateError('provider has not been initialized');
}

extension RefX<TState> on ProviderRef<TState> {
  T conf<T>(T Function(Config config) selector) =>
      watch(riverpodConfigProvider.select(selector));

  T readConf<T>(T Function(Config config) selector) =>
      read(riverpodConfigProvider.select(selector));
}
