import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferencesInit(
  SharedPreferencesInitRef ref,
) async =>
    SharedPreferences.getInstance();

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) =>
    switch (ref.watch(sharedPreferencesInitProvider)) {
      AsyncData(value: final sharedPreferences) => sharedPreferences,
      _ => throw StateError('sharedPreferences have not been initialized!'),
    };
