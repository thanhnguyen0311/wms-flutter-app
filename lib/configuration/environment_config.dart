class EnvironmentConfig {
  static const String env = String.fromEnvironment('APP_ENV', defaultValue: 'production');

  static String get apiBaseUrl {
    return 'https://ewfportal.com/api/v1/';
  }
}