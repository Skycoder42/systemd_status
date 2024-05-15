import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../gen/l10n/app_localizations.dart';

export '../../gen/l10n/app_localizations.dart' show AppLocalizations;

const localizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  FormBuilderLocalizations.delegate,
];

extension BuildContextX on BuildContext {
  AppLocalizations get strings => AppLocalizations.of(this);
}
