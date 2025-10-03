import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart' as pkg;

import '../config/app_config.dart';

class VersionPolicy {
  final int minBuild; // minimum supported build number
  final String minVersion; // minimum supported semantic version e.g., 1.0.1
  final String? androidUrl; // Play Store URL
  final String? iosUrl; // App Store URL
  final String? message; // Optional server-provided message to show users

  VersionPolicy({
    required this.minBuild,
    required this.minVersion,
    this.androidUrl,
    this.iosUrl,
    this.message,
  });

  factory VersionPolicy.fromJson(Map<String, dynamic> json) => VersionPolicy(
        minBuild: (json['minBuild'] ?? json['min_build'] ?? 1) as int,
        minVersion: (json['minVersion'] ?? json['min_version'] ?? '1.0.0') as String,
        androidUrl: json['androidUrl'] ?? json['android_url'] as String?,
        iosUrl: json['iosUrl'] ?? json['ios_url'] as String?,
        message: json['message'] as String?,
      );
}

class VersionCheckResult {
  final bool requiredUpdate;
  final String storeUrl; // where to update
  final String? message;

  VersionCheckResult({
    required this.requiredUpdate,
    required this.storeUrl,
    this.message,
  });
}

class VersionService {
  /// Check remote policy and compare with current version/build.
  /// Returns a result indicating whether update is required and the store URL.
  static Future<VersionCheckResult> checkForMandatoryUpdate() async {
    // Current app info
    final info = await pkg.PackageInfo.fromPlatform();
    final currentVersion = info.version; // e.g., 1.0.0
    final currentBuild = int.tryParse(info.buildNumber) ?? 1; // e.g., 1

    // Fetch remote policy
    try {
      final resp = await http
          .get(Uri.parse(AppConfig.versionCheckUrl))
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final policy = VersionPolicy.fromJson(data);
        return _evaluate(policy, currentVersion, currentBuild);
      } else {
        if (kDebugMode) {
          print('Version check failed with status: ${resp.statusCode}');
        }
      }
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('Version check SocketException: $e');
      }
    } on FormatException catch (e) {
      if (kDebugMode) {
        print('Version check JSON parse error: $e');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Version check unexpected error: $e');
      }
    }

    // Fallback to local policy on failure
    final fallback = VersionPolicy(
      minBuild: AppConfig.minSupportedBuildFallback,
      minVersion: AppConfig.minSupportedVersionFallback,
      androidUrl: AppConfig.playStoreUrl,
      iosUrl: AppConfig.appStoreUrl,
      message: null,
    );
    return _evaluate(fallback, currentVersion, currentBuild);
  }

  static VersionCheckResult _evaluate(
    VersionPolicy policy,
    String currentVersion,
    int currentBuild,
  ) {
    final requiresByBuild = currentBuild < policy.minBuild;
    final requiresBySemver = _compareSemver(currentVersion, policy.minVersion) < 0;
    final requiredUpdate = requiresByBuild || requiresBySemver;

    final storeUrl = Platform.isIOS
        ? (policy.iosUrl ?? AppConfig.appStoreUrl)
        : (policy.androidUrl ?? AppConfig.playStoreUrl);

    return VersionCheckResult(
      requiredUpdate: requiredUpdate,
      storeUrl: storeUrl,
      message: policy.message,
    );
  }

  /// Compare two semver strings like 1.2.3. Returns -1, 0, 1.
  static int _compareSemver(String a, String b) {
    final ap = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final bp = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    while (ap.length < 3) ap.add(0);
    while (bp.length < 3) bp.add(0);
    for (var i = 0; i < 3; i++) {
      if (ap[i] != bp[i]) return ap[i] < bp[i] ? -1 : 1;
    }
    return 0;
  }
}