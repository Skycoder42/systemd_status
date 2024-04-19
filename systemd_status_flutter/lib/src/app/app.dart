import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../localization/localization.dart';
import '../providers/shared_preferences_provider.dart';
import 'router.dart';
import 'theme.dart';

part 'app.g.dart';

@riverpod
Future<void> appInit(AppInitRef ref) async => Future.wait([
      ref.watch(sharedPreferencesInitProvider.future),
    ]);

class SystemdStatusApp extends ConsumerWidget {
  const SystemdStatusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      switch (ref.watch(appInitProvider)) {
        AsyncData() => MaterialApp.router(
            routerConfig: ref.watch(routerProvider),
            restorationScopeId: 'systemd-status-app',

            // localization
            localizationsDelegates: localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateTitle: (context) => context.strings.app_name,

            // theming
            color: SystemdStatusTheme.appColor,
            theme: ref.watch(appThemeProvider(Brightness.light)),
            darkTheme: ref.watch(appThemeProvider(Brightness.dark)),
            themeMode: ThemeMode.light,
          ),
        _ => MaterialApp(
            // localization
            localizationsDelegates: localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateTitle: (context) => context.strings.app_name,

            // theming
            color: SystemdStatusTheme.appColor,
            theme: ref.watch(appThemeProvider(Brightness.light)),
            darkTheme: ref.watch(appThemeProvider(Brightness.dark)),
            themeMode: ThemeMode.light,

            // content
            home: const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      };
}