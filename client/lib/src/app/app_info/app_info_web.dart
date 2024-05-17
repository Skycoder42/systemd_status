import 'package:web/web.dart';

abstract base class AppInfo {
  AppInfo._();

  static String? get staticServerUrl => window.location.origin;
}
