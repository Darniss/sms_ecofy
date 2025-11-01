class EnvironmentConfig {
  // Use bool.fromEnvironment to check for a compile-time flag
  // To compile for production: flutter build --dart-define=IS_PRODUCTION=true
  static const bool isProduction = bool.fromEnvironment('IS_PRODUCTION');

  // This can be toggled at runtime, but defaults to false if in production
  static bool isTestMode = !isProduction;
}
