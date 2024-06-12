import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../localization/localization.dart';
import 'setup_page.dart';

class SetupApp extends ConsumerWidget {
  final Completer<Uri> serverUrlCompleter;

  const SetupApp({
    super.key,
    required this.serverUrlCompleter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
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
        home: FutureBuilder(
          future: serverUrlCompleter.future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text(snapshot.error.toString()),
                ),
              );
            }

            return SetupPage(
              serverUrlCompleter: serverUrlCompleter,
            );
          },
        ),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<Completer<Uri>>(
        'serverUrlCompleter',
        serverUrlCompleter,
      ),
    );
  }
}
