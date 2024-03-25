import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../pages/units/units_page.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) => GoRouter(
      routes: $appRoutes,
    );

@TypedGoRoute<RootRoute>(path: '/')
@immutable
class RootRoute extends GoRouteData {
  const RootRoute();

  @override
  String redirect(BuildContext context, GoRouterState state) =>
      const UnitsRoute().location;
}

@TypedGoRoute<UnitsRoute>(path: '/units')
@immutable
class UnitsRoute extends GoRouteData {
  const UnitsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const UnitsPage();
}
