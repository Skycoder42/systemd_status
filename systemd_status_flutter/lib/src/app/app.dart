import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/localization.dart';
import 'router.dart';
import 'theme.dart';

class SystemdStatusApp extends ConsumerWidget {
  const SystemdStatusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        routerConfig: ref.watch(routerProvider),
        restorationScopeId: 'systemd-status-app',

        // localization
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateTitle: (context) => context.strings.app_name,

        // theming
        color: SystemdStatusTheme.appColor,
        theme: ref.watch(appThemeProvider(Brightness.light)),
        darkTheme: ref.watch(appThemeProvider(Brightness.dark)),
        themeMode: ThemeMode.light,
      );
}
