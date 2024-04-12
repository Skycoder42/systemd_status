import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:serverpod_auth_email_flutter/serverpod_auth_email_flutter.dart';
import 'package:serverpod_auth_google_flutter/serverpod_auth_google_flutter.dart';

import '../../app/router.dart';
import '../../localization/localization.dart';
import '../../providers/client_provider.dart';
import '../../services/app_settings.dart';
import '../../widgets/error_snack_bar.dart';

class LoginPage extends ConsumerWidget {
  final String? redirectTo;

  const LoginPage({
    super.key,
    this.redirectTo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final googleAuthSettings = ref.watch(
      appSettingsProvider.select((s) => s.googleAuthSettings),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.login_page_title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (googleAuthSettings != null) ...[
              SignInWithGoogleButton(
                caller: ref.watch(systemdStatusClientProvider).modules.auth,
                clientId: googleAuthSettings.clientId,
                serverClientId: googleAuthSettings.serverClientId,
                redirectUri: googleAuthSettings.redirectUri,
                debug: kDebugMode,
                onSignedIn: () =>
                    context.go(redirectTo ?? const RootRoute().location),
                onFailure: () => ScaffoldMessenger.of(context).showSnackBar(
                  ErrorSnackBar(
                    context: context,
                    content: Text(context.strings.google_auth_failed),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            SignInWithEmailButton(
              caller: ref.watch(systemdStatusClientProvider).modules.auth,
              onSignedIn: () =>
                  context.go(redirectTo ?? const RootRoute().location),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('redirectTo', redirectTo));
  }
}
