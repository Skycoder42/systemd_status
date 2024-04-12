import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_email_flutter/serverpod_auth_email_flutter.dart';
import 'package:serverpod_auth_google_flutter/serverpod_auth_google_flutter.dart';

import '../../app/router.dart';
import '../../localization/localization.dart';
import '../../providers/client_provider.dart';
import '../../services/app_settings.dart';
import '../../widgets/error_snack_bar.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final googleAuthSettings = ref.watch(
      appSettingsProvider.select((s) => s.googleAuthSettings),
    );
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (googleAuthSettings != null)
            SignInWithGoogleButton(
              caller: ref.watch(systemdStatusClientProvider).modules.auth,
              clientId: googleAuthSettings.clientId,
              serverClientId: googleAuthSettings.serverClientId,
              redirectUri: googleAuthSettings.redirectUri,
              debug: kDebugMode,
              onSignedIn: () => const RootRoute().go(context),
              onFailure: () => ScaffoldMessenger.of(context).showSnackBar(
                ErrorSnackBar(
                  context: context,
                  content: Text(context.strings.google_auth_failed),
                ),
              ),
            ),
          SignInWithEmailButton(
            caller: ref.watch(systemdStatusClientProvider).modules.auth,
            onSignedIn: () => const RootRoute().go(context),
          ),
        ],
      ),
    );
  }
}
