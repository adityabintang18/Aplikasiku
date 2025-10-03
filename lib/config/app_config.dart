/// Global App configuration values.
///
/// Move environment-specific values (like URLs) here instead of hardcoding
/// them across services. See repository_rules for guidance.
class AppConfig {
  AppConfig._();

  /// Endpoint returning version policy.
  /// Expected JSON example (customize to your backend):
  /// {
  ///   "minBuild": 2,
  ///   "minVersion": "1.0.1",
  ///   "androidUrl": "https://play.google.com/store/apps/details?id=com.example.aplikasiku",
  ///   "iosUrl": "https://apps.apple.com/app/id0000000000",
  ///   "message": "Versi baru tersedia. Silakan update untuk melanjutkan."
  /// }
  static const String versionCheckUrl =
      "http://192.168.1.10:8000/app/version"; // TODO: set real endpoint

  /// Store URLs fallback if server does not provide platform-specific links
  static const String playStoreUrl =
      "https://play.google.com/store/apps/details?id=com.example.aplikasiku";
  static const String appStoreUrl = "https://apps.apple.com/app/id0000000000";

  /// Fallback policy if remote check fails (offline, server error, etc.)
  static const int minSupportedBuildFallback = 1; // current build is 1
  static const String minSupportedVersionFallback =
      "1.0.0"; // current version is 1.0.0
}
