import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasiku/services/auth_service.dart';
import 'package:aplikasiku/services/api_client.dart';

class UserService {
  static const String _baseUrl = 'https://api-mobile.indoprosmamandiri.my.id';
  static final ApiClient _api = ApiClient(baseUrl: _baseUrl);

  static Future<Map<String, dynamic>?> getProfile() async {
    // Cek token expired dulu
    final expired = await AuthService.isTokenExpired();
    if (expired) {
      return null;
    }

    final prefs = await SharedPreferences.getInstance();

    final response = await _api.get('profile'); // tanpa context

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // simpan nama terbaru ke SharedPreferences
      if (data['name'] != null) {
        await prefs.setString('user_name', data['name']);
      }
      return data;
    } else {
      return null;
    }
  }
}
