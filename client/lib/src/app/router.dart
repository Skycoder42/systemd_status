import 'package:dio/dio.dart';
import 'package:firebase_auth_rest/firebase_auth_rest.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../pages/login/login_page.dart';
import '../pages/setup/setup_page.dart';
import '../pages/setup/sever_unreachable_page.dart';
import '../pages/units/units_page.dart';
import 'auth/account_manager_provider.dart';
import 'config/app_settings.dart';

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
  static final _whitelistedRoutes = [
    const SetupRoute().location,
    const ServerUnreachableRoute().location,
    const LoginRoute().location,
  ];

  final _GlobalRedirectRef ref;
  final _logger = Logger('GlobalRedirect');

  _GlobalRedirect(this.ref);

  String? call(BuildContext context, GoRouterState state) {
    if (_whitelistedRoutes
        .any((route) => state.fullPath?.startsWith(route) ?? false)) {
      return null;
    }

    if (_checkSetupRedirect(state) case final String redirect) {
      return redirect;
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

  String? _checkSetupRedirect(GoRouterState state) {
    _logger.finest('Checking setup redirection for ${state.matchedLocation}');
    final setupState = ref.read(settingsLoaderProvider);
    switch (setupState) {
      case AsyncData(value: true):
        _logger.finest('Client configuration is working and up to date');
        return null;
      case AsyncData(value: false):
        _logger.config('No serverUrl configured. Redirecting to setup page');
        return SetupRoute(redirectTo: state.matchedLocation).location;
      case AsyncError(error: DioException()):
        _logger.config(
          'Server unreachable. Redirecting to server unreachable page',
        );
        return const ServerUnreachableRoute().location;
      case AsyncError():
        _logger.config(
          'Failed to load client configuration. Redirecting to setup page',
        );
        return SetupRoute(
          redirectTo: state.matchedLocation,
          hasError: true,
        ).location;
      default:
        _logger.severe('Unknown setup state: $setupState');
        return null;
    }
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
