import 'package:firebase_auth_rest/firebase_auth_rest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../pages/login/login_page.dart';
import '../pages/login/logout_dialog.dart';
import '../pages/logs/logs_page.dart';
import '../pages/restart/restart_dialog.dart';
import '../pages/units/units_page.dart';
import 'auth/account_manager_provider.dart';
import 'pages/dialog_page.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) => GoRouter(
      routes: $appRoutes,
      redirect: ref.watch(_globalRedirectProvider).call,
      observers: [
        if (Sentry.isEnabled) SentryNavigatorObserver(),
      ],
    );

@riverpod
_GlobalRedirect _globalRedirect(Ref ref) => _GlobalRedirect(ref);

class _GlobalRedirect {
  static final _whitelistedRoutes = [
    const LoginRoute().location,
  ];

  final Ref ref;
  final _logger = Logger('GlobalRedirect');

  _GlobalRedirect(this.ref);

  String? call(BuildContext context, GoRouterState state) {
    if (_whitelistedRoutes
        .any((route) => state.fullPath?.startsWith(route) ?? false)) {
      return null;
    }

    if (_checkLoginRedirect(state) case final String redirect) {
      return redirect;
    }

    _logger.finer(
      'No redirection required. '
      'Continuing normal navigation to ${state.fullPath}',
    );
    return null;
  }

  String? _checkLoginRedirect(GoRouterState state) {
    _logger.finest('Checking login for ${state.matchedLocation}');
    final accountState = ref.read(accountManagerProvider);
    switch (accountState) {
      case AsyncData(value: FirebaseAccount()):
        _logger.finest('User is logged in');
        return null;
      case AsyncData(value: null):
        _logger.config('Not logged in redirecting to login page');
        return LoginRoute(redirectTo: state.matchedLocation).location;
      case AsyncError():
        _logger.config(
          'Failed to load account. Redirecting to login page',
        );
        return LoginRoute(redirectTo: state.matchedLocation).location;
      default:
        _logger.severe('Unknown account state: $accountState');
        return null;
    }
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

@TypedGoRoute<UnitsRoute>(
  path: '/units',
  routes: [
    TypedGoRoute<LogsRoute>(path: ':unitName/logs'),
    TypedGoRoute<RestartUnitRoute>(path: ':unitName/restart'),
  ],
)
@immutable
class UnitsRoute extends GoRouteData {
  const UnitsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const UnitsPage();
}

@immutable
class LogsRoute extends GoRouteData {
  final String unitName;

  const LogsRoute(this.unitName);

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      LogsPage(unitName: unitName);
}

class RestartUnitRoute extends GoRouteData {
  final String unitName;

  RestartUnitRoute(this.unitName);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => DialogPage(
        state: state,
        builder: (context) => RestartDialog(unit: unitName),
      );
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

@TypedGoRoute<LogoutRoute>(path: '/logout')
@immutable
class LogoutRoute extends GoRouteData {
  const LogoutRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => DialogPage(
        state: state,
        barrierDismissible: false,
        builder: (context) => const LogoutDialog(),
      );
}
