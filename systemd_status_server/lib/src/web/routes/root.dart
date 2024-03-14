import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../widgets/default_page_widget.dart';

class RouteRoot extends WidgetRoute {
  @override
  Future<Widget> build(Session session, HttpRequest request) async =>
      DefaultPageWidget();
}
