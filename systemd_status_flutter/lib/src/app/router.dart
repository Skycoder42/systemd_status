import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../pages/login/login_page.dart';
import '../pages/units/units_page.dart';
import '../providers/client_provider.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) => GoRouter(
      routes: $appRoutes,
      redirect: ref.watch(_globalRedirectProvider).call,
    );

@riverpod
_GlobalRedirect _globalRedirect(_GlobalRedirectRef ref) => _GlobalRedirect(ref);

class _GlobalRedirect {
  final _GlobalRedirectRef ref;

  _GlobalRedirect(this.ref);

  Future<String?> call(BuildContext context, GoRouterState state) async {
    final sessionManager = await ref.read(sessionManagerProvider.future);
    if (sessionManager.isSignedIn) {
      return null;
    }

    return const LoginRoute().location;
  }
}

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

@TypedGoRoute<LoginRoute>(path: '/login')
@immutable
class LoginRoute extends GoRouteData {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginPage();
}
