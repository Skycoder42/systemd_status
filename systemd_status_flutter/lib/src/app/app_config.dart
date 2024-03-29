abstract base class AppConfig {
  AppConfig._();

  static const serverClientId =
      String.fromEnvironment('GOOGLE_AUTH_SERVER_CLIENT_ID');

  static final redirectUri = Uri.parse(
    const String.fromEnvironment('GOOGLE_AUTH_REDIRECT_URI'),
  );
}
