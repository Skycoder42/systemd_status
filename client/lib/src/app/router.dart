import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../pages/login/login_page.dart';
import '../pages/setup/setup_page.dart';
import '../pages/units/units_page.dart';
import '../settings/app_settings.dart';

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
  final _logger = Logger('GlobalRedirect');

  _GlobalRedirect(this.ref);

  String? call(BuildContext context, GoRouterState state) {
    final appSettings = ref.read(appSettingsProvider);
    if (appSettings.serverUrl == null) {
      _logger.config('No serverUrl configured. Redirecting to setup page');
      return SetupRoute(redirectTo: state.matchedLocation).location;
    }

    _logger.finest(
      'No redirection required. '
      'Continuing normal navigation to ${state.fullPath}',
    );
    return null;
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

@TypedGoRoute<SetupRoute>(path: '/setup')
@immutable
class SetupRoute extends GoRouteData {
  final String? redirectTo;

  const SetupRoute({this.redirectTo});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      SetupPage(redirectTo: redirectTo);
}

@TypedGoRoute<LoginRoute>(path: '/login')
@immutable
class LoginRoute extends GoRouteData {
  final String? redirectTo;

  const LoginRoute({this.redirectTo});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      LoginPage(redirectTo: redirectTo);
}
