import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

export 'package:flutter_gen/gen_l10n/app_localizations.dart'
    show AppLocalizations;

extension BuildContextX on BuildContext {
  AppLocalizations get strings => AppLocalizations.of(this);
}
