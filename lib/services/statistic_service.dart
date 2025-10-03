import 'dart:convert';
import 'package:flutter/material.dart';
import 'api_client.dart';

class StatisticsService {
  final ApiClient _apiClient = ApiClient(baseUrl: 'http://192.168.1.10:8000/');

  Future<Map<String, dynamic>> getStatistics({BuildContext? context}) async {
    final response = await _apiClient.get('statistics/overview', context);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Pastikan data sudah dalam format Map<String, dynamic>
      return data as Map<String, dynamic>;
    } else {
      throw Exception('Gagal mengambil data statistik: ${response.statusCode}');
    }
  }
}
