import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_google_flutter/serverpod_auth_google_flutter.dart';

import '../../app/router.dart';
import '../../providers/client_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: Center(
          child: SignInWithGoogleButton(
            caller: ref.watch(systemdStatusClientProvider).modules.auth,
            serverClientId:
                '71998325916-aek6tmbtcdlkd157dp1t61r7u59vje5s.apps.googleusercontent.com',
            redirectUri: Uri.parse('http://localhost:8082/googlesignin'),
            debug: kDebugMode,
            onSignedIn: () => const RootRoute().go(context),
            onFailure: () {
              print('FAILED TO LOGIN!!!');
            },
          ),
        ),
      );
}
