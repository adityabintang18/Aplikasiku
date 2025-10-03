import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class VersionService {
  static const String _baseUrl =
      "http://192.168.1.10:8000/api"; // ganti sesuai server

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
}
