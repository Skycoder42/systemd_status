import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../pages/login/login_page.dart';
import '../pages/setup/restart_app_page.dart';
import '../pages/setup/setup_page.dart';
import '../pages/setup/sever_unreachable_page.dart';
import '../pages/units/units_page.dart';
import '../settings/setup_loader.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) => GoRouter(
      routes: $appRoutes,
      redirect: ref.watch(_globalRedirectProvider).call,
      observers: [
        if (Sentry.isEnabled) SentryNavigatorObserver(),
      ],
    );

@riverpod
_GlobalRedirect _globalRedirect(_GlobalRedirectRef ref) => _GlobalRedirect(ref);

class _GlobalRedirect {
  final _GlobalRedirectRef ref;
  final _logger = Logger('GlobalRedirect');

  _GlobalRedirect(this.ref);

  String? call(BuildContext context, GoRouterState state) {
    if (state.fullPath?.startsWith(const SetupRoute().location) ?? false) {
      return null;
    }

    _logger.finest('Checking redirection for ${state.matchedLocation}');
    final setupState = ref.read(setupStateProvider);
    switch (setupState) {
      case SetupUnchangedState():
        _logger.finest('Client configuration is working and up to date');
      case SetupRequiredState(withError: final hasError):
        _logger.config('No serverUrl configured. Redirecting to setup page');
        return SetupRoute(
          redirectTo: state.matchedLocation,
          hasError: hasError,
        ).location;
      case SetupRefreshedState():
        _logger.config(
          'Received updated configuration from server. '
          'Redirecting to restart page',
        );
        return const RestartAppRoute().location;
      case SetupServerUnreachableState():
        _logger.config(
          'Server unreachable. Redirecting to server unreachable page',
        );
        return const ServerUnreachableRoute().location;
    }

    _logger.finer(
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

@TypedGoRoute<SetupRoute>(
  path: '/setup',
  routes: [
    TypedGoRoute<RestartAppRoute>(path: 'restart'),
    TypedGoRoute<ServerUnreachableRoute>(path: 'offline'),
  ],
)
@immutable
class SetupRoute extends GoRouteData {
  final String? redirectTo;
  final bool hasError;

  const SetupRoute({this.redirectTo, this.hasError = false});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      SetupPage(redirectTo: redirectTo, hasError: hasError);
}

@immutable
class RestartAppRoute extends GoRouteData {
  const RestartAppRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RestartAppPage();
}

@immutable
class ServerUnreachableRoute extends GoRouteData {
  const ServerUnreachableRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ServerUnreachablePage();
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
