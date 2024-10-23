import 'package:firebase_verify_id_tokens/firebase_verify_id_tokens.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/server_config.dart';

part 'firebase_verify_token_id_provider.g.dart';

@Riverpod(keepAlive: true)
FirebaseVerifyTokenId firebaseVerifyTokenId(Ref ref) => FirebaseVerifyTokenId(
      ref.watch(serverConfigProvider.select((c) => c.firebase.projectId)),
    );
