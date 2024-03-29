import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_email_flutter/serverpod_auth_email_flutter.dart';
import 'package:serverpod_auth_google_flutter/serverpod_auth_google_flutter.dart';

import '../../app/app_config.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../localization/localization.dart';
import '../../providers/client_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SignInWithGoogleButton(
              caller: ref.watch(systemdStatusClientProvider).modules.auth,
              serverClientId: AppConfig.serverClientId,
              redirectUri: AppConfig.redirectUri,
              debug: kDebugMode,
              onSignedIn: () => const RootRoute().go(context),
              onFailure: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: context.theme.colorScheme.error,
                  content: Text(
                    context.strings.google_auth_failed,
                    style: TextStyle(
                      color: context.theme.colorScheme.onError,
                    ),
                  ),
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
