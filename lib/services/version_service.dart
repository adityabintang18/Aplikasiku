import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class VersionCheckResult {
  final bool requiredUpdate;
  final String storeUrl;
  final String message;

  VersionCheckResult({
    required this.requiredUpdate,
    required this.storeUrl,
    required this.message,
  });

  factory VersionCheckResult.fromJson(Map<String, dynamic> json) {
    return VersionCheckResult(
      requiredUpdate: json['requiredUpdate'] ?? false,
      storeUrl: json['storeUrl'] ?? '',
      message: json['message'] ?? 'Versi terbaru sudah tersedia',
    );
  }
}

class VersionService {
  static const String _baseUrl =
      "https://api-mobile.indoprosmamandiri.my.id/api"; // ganti sesuai server

  /// update versi saat build/release
  static Future<void> updateVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();

    final platform = "android"; // bisa dibuat dinamis kalau perlu
    final version = "${packageInfo.version}+${packageInfo.buildNumber}";

    final url = Uri.parse("$_baseUrl/version/update");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "platform": platform,
        "version": version,
      }),
    );

    if (response.statusCode == 200) {
      print("✅ Version update success: ${response.body}");
    } else {
      print("❌ Failed update: ${response.statusCode} - ${response.body}");
    }
  }

  /// cek mandatory update saat app dibuka
  static Future<VersionCheckResult> checkForMandatoryUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();

    final platform = "android";
    final currentVersion = "${packageInfo.version}+${packageInfo.buildNumber}";

    final url = Uri.parse(
        "$_baseUrl/version/check?platform=$platform&version=$currentVersion");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("ℹ️ Version check result: $data");
      return VersionCheckResult.fromJson(data);
    } else {
      throw Exception("❌ Failed to check version: ${response.statusCode}");
    }
  }
}
