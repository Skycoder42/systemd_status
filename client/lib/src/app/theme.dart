import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme.g.dart';

@riverpod
ThemeData appTheme(AppThemeRef ref, Brightness brightness) =>
    SystemdStatusTheme.createFor(brightness);

abstract base class SystemdStatusTheme {
  SystemdStatusTheme._();

  static const appColor = Color(0xFF30d475);

  static ThemeData createFor(Brightness brightness) => ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          brightness: brightness,
          seedColor: appColor,
        ),
      );
}

extension BuildContextThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
}
