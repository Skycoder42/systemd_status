import 'dart:io';

import 'package:firebase_verify_id_tokens/firebase_verify_id_tokens.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_api/shelf_api.dart';

import '../config/server_config.dart';
import '../providers/firebase_verify_token_id_provider.dart';

part 'firebase_auth.g.dart';
part 'firebase_auth.freezed.dart';

Middleware firebaseAuth() => _FirebaseAuthMiddleware().call;

@Riverpod(dependencies: [shelfRequest])
UserInfo userInfo(Ref ref) => ref.read(shelfRequestProvider).userInfo;

extension FirebaseAuthX on Request {
  UserInfo get userInfo =>
      context[_FirebaseAuthMiddleware._userInfoKey]! as UserInfo;
}

@freezed
sealed class _AuthResult with _$AuthResult {
  const factory _AuthResult.success(UserInfo userInfo) = _AuthSuccess;
  const factory _AuthResult.failure(Response response) = _AuthFailure;
}

class _FirebaseAuthMiddleware {
  static const _userInfoKey = 'FirebaseAuthMiddleware.userId';
  static final _authHeaderPattern = RegExp(r'^Bearer (.*)$');

  final _logger = Logger('FirebaseAuthMiddleware');

  Handler call(Handler next) => (request) async {
        final authResult = await _checkAuthorization(request);
        switch (authResult) {
          case _AuthSuccess(userInfo: final userInfo):
            return await next(
              request.change(
                context: {
                  _userInfoKey: userInfo,
                },
              ),
            );
          case _AuthFailure(response: final response):
            return response;
        }
      };

  Future<_AuthResult> _checkAuthorization(Request request) async {
    final authHeader = request.headers[HttpHeaders.authorizationHeader];
    if (authHeader == null) {
      _logger.warning('Rejecting request with missing auth header');
      return _AuthResult.failure(Response.unauthorized(null));
    }

    final authHeaderMatch = _authHeaderPattern.firstMatch(authHeader);
    if (authHeaderMatch == null) {
      _logger.warning('Rejecting request with invalid auth header');
      return _AuthResult.failure(Response.unauthorized(null));
    }

    final idToken = authHeaderMatch[1]!;
    final verifier = request.ref.read(firebaseVerifyTokenIdProvider);
    try {
      final userId = await verifier.getUidFromToken(idToken);
      if (userId.isEmpty) {
        _logger.warning(
          'Rejecting request because idToken does not contain a userId',
        );
        return _AuthResult.failure(Response(HttpStatus.forbidden));
      }

      final whitelist = request.ref.read(serverConfigProvider).firebase.users;
      final userInfo = whitelist?.where((u) => u.uid == userId).firstOrNull;
      if (whitelist != null && userInfo == null) {
        _logger.warning(
          'Rejecting request because user with id $userId '
          'has not been whitelisted',
        );
        return _AuthResult.failure(Response(HttpStatus.forbidden));
      }

      return _AuthResult.success(userInfo ?? UserInfo(uid: userId));
    } on FirebaseIdTokenException catch (e, s) {
      _logger.warning(
        'Rejecting request with token validation error',
        e,
        s,
      );
      return _AuthResult.failure(Response.unauthorized(e.message));

      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      _logger.severe('Rejecting request with unexpected error', e, s);
      return _AuthResult.failure(Response.unauthorized(null));
    }
  }
}
