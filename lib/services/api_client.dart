import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart' as pkg;
import 'auth_service.dart';
import 'package:aplikasiku/presentation/screens/auth/sign_in_screen.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  Future<void> _checkTokenExpired(BuildContext? context) async {
    if (context == null) return;
    final expired = await AuthService.isTokenExpired();
    if (expired) {
      await AuthService.logout();
      // Redirect ke halaman login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
      throw Exception('Token sudah expired, silakan login ulang.');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    final info = await pkg.PackageInfo.fromPlatform();
    final appVersion = info.version;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-App-Version': appVersion,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint, [BuildContext? context]) async {
    await _checkTokenExpired(context);
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = await _getHeaders();
    return await http.get(url, headers: headers);
  }

  Future<http.Response> post(
      String endpoint, Map<String, dynamic> body, [BuildContext? context]) async {
    await _checkTokenExpired(context);
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = await _getHeaders();
    return await http.post(url, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> put(
      String endpoint, Map<String, dynamic> body, [BuildContext? context]) async {
    await _checkTokenExpired(context);
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = await _getHeaders();
    return await http.put(url, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> delete(String endpoint, [BuildContext? context]) async {
    await _checkTokenExpired(context);
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = await _getHeaders();
    return await http.delete(url, headers: headers);
  }

  Future<http.StreamedResponse> postMultipart(
      String endpoint,
      Map<String, String> fields,
      Map<String, http.MultipartFile> files,
      [BuildContext? context]) async {
    await _checkTokenExpired(context);
    final url = Uri.parse('$baseUrl/$endpoint');
    final request = http.MultipartRequest('POST', url);
    final token = await AuthService.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    final info = await pkg.PackageInfo.fromPlatform();
    request.headers['X-App-Version'] = info.version;
    request.headers['Accept'] = 'application/json';
    // jangan set Content-Type manual, biar MultipartRequest yang set boundary
    request.fields.addAll(fields);
    files.forEach((key, file) {
      request.files.add(file);
    });
    return await request.send();
  }
}
