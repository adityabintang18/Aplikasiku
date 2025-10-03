import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'api_client.dart';
import 'package:get/get.dart';
import 'package:aplikasiku/app_routes.dart';

class AuthService {
  static const String baseUrl = "http://192.168.1.10:8000";

  static final ApiClient _api = ApiClient(baseUrl: baseUrl);

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        'login',
        {
          'email': username,
          'password': password,
        },
      );

      final url = Uri.parse('$baseUrl/login');
      print('🔗 Request ke: $url');
      print('📤 Body: {email: $username, password: ****}');
      print('📥 Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final token = data['token']?.toString();
        if (token != null && token.isNotEmpty) {
          await _saveToken(token);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('last_user_email', username);
          try {
            final user = data['user'];
            final uid = (user is Map && user['id'] != null)
                ? user['id'].toString()
                : (data['id']?.toString());
            if (uid != null) {
              await prefs.setString('last_user_id', uid);
            }
          } catch (_) {}
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Login berhasil',
          'data': data,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Email atau password salah',
        };
      } else if (response.statusCode == 422) {
        return {
          'success': false,
          'message': 'Data yang dikirim tidak valid',
          'errors': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal login. Kode: ${response.statusCode}',
          'body': response.body,
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'Tidak bisa terhubung ke server. Periksa koneksi internet.',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timeout. Server tidak merespon.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi error: $e',
      };
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // aman walau null
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _api.post(
        'register',
        {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final url = Uri.parse('$baseUrl/register');
      print('🔗 Request ke: $url');
      print('📤 Body: {name: $name, email: $email, password: ****}');
      print('📥 Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Registrasi berhasil',
          'data': data,
        };
      } else if (response.statusCode == 422) {
        return {
          'success': false,
          'message': 'Data tidak valid',
          'errors': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal registrasi (${response.statusCode})',
          'body': response.body,
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'Tidak bisa terhubung ke server. Periksa koneksi internet.',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timeout. Server tidak merespon.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getProfile(BuildContext context) async {
    try {
      final response = await _api.get('profile', context);

      print('📥 Profile Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal ambil profile (${response.statusCode})',
        };
      }
    } catch (e) {
      // Kalau token expired, ApiClient sudah throw Exception → bisa tangani disini
      return {
        'success': false,
        'message': 'Terjadi error: $e',
      };
    }
  }

  static Future<bool> isTokenExpired() async {
    final token = await getToken();
    if (token == null) return true; // token tidak ada → dianggap expired
    return JwtDecoder.isExpired(token);
  }

  static Future<void> checkAndLogoutIfExpired(BuildContext context,
      {VoidCallback? onLoggedOut}) async {
    final token = await getToken();
    if (token != null && JwtDecoder.isExpired(token)) {
      await logout();
      if (onLoggedOut != null) onLoggedOut();
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
