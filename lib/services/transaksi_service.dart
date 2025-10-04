import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:aplikasiku/models/model.dart';
import 'package:aplikasiku/services/api_client.dart';
import 'package:http/http.dart' as http;

class TransaksiService {
  static final ApiClient _apiClient = ApiClient(
      baseUrl: 'https://api-mobile.indoprosmamandiri.my.id/finansial');

  // context wajib dikirim dari widget, karena ApiClient butuh context untuk cek token expired
  static Future<List<TransaksiModel>> getAll(BuildContext context) async {
    print('[TransaksiService] Request GET ke ${_apiClient.baseUrl}');
    final response = await _apiClient.get('', context);

    print('[TransaksiService] Response status: ${response.statusCode}');
    print('[TransaksiService] Response body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => TransaksiModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data transaksi');
    }
  }

  static Future<List<TransaksiModel>> getByMonth(
      DateTime date, BuildContext context) async {
    final endpoint = '?month=${date.month}&year=${date.year}';
    print('[TransaksiService] Request GET ke ${_apiClient.baseUrl}$endpoint');
    final response = await _apiClient.get(endpoint, context);

    print('[TransaksiService] Response status: ${response.statusCode}');
    print('[TransaksiService] Response body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => TransaksiModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data transaksi per bulan');
    }
  }

  static Future<List<Map<String, dynamic>>> getMonthlySummary(
      DateTime date, BuildContext context,
      {int? jenisKategori}) async {
    final queryJenis =
        jenisKategori != null ? '&jenis_kategori=$jenisKategori' : '';
    final endpoint = 'summary?month=${date.month}&year=${date.year}$queryJenis';
    print('[TransaksiService] Request GET ke ${_apiClient.baseUrl}/$endpoint');
    final response = await _apiClient.get(endpoint, context);
    print('[TransaksiService] Response status: ${response.statusCode}');
    print('[TransaksiService] Response body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Gagal mengambil ringkasan bulanan');
    }
  }

  static Future<List<Map<String, dynamic>>> getCalendar(
      DateTime date, BuildContext context,
      {int? jenisKategori}) async {
    final queryJenis =
        jenisKategori != null ? '&jenis_kategori=$jenisKategori' : '';
    final endpoint =
        'calendar?month=${date.month}&year=${date.year}$queryJenis';
    print('[TransaksiService] Request GET ke ${_apiClient.baseUrl}/$endpoint');
    final response = await _apiClient.get(endpoint, context);
    print('[TransaksiService] Response status: ${response.statusCode}');
    print('[TransaksiService] Response body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Gagal mengambil data kalender');
    }
  }

  static Future<List<TransaksiModel>> getByJenisKategori(
      String jenisKategori, BuildContext context) async {
    final endpoint = 'jenis?jenis_kategori=$jenisKategori';
    print('[TransaksiService] Request GET ke ${_apiClient.baseUrl}/$endpoint');
    final response = await _apiClient.get(endpoint, context);

    print('[TransaksiService] Response status: ${response.statusCode}');
    print('[TransaksiService] Response body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => TransaksiModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data transaksi per jenis kategori');
    }
  }

  static Future<void> add(
      TransaksiModel transaksi, BuildContext context) async {
    print('[TransaksiService] Request POST ke ${_apiClient.baseUrl}');
    if (transaksi.photoPath != null && transaksi.photoPath!.isNotEmpty) {
      // Kirim multipart
      final fields = <String, String>{
        'title': transaksi.title,
        'category': (transaksi.category ?? '').toString(),
        'jenis_kategori': (transaksi.jenisKategori ?? '').toString(),
        'date': transaksi.date.toIso8601String(),
        'amount': transaksi.amount.toString(),
        'is_income': transaksi.isIncome ? '1' : '0',
        if (transaksi.description != null)
          'description': transaksi.description!,
      };
      print('[TransaksiService] Multipart fields: $fields');
      final file = await http.MultipartFile.fromPath(
        'photo',
        transaksi.photoPath!,
      );
      final streamed = await _apiClient.postMultipart(
        '',
        fields,
        {'photo': file},
        context,
      );
      final response = await http.Response.fromStream(streamed);
      print('[TransaksiService] Response status: ${response.statusCode}');
      print('[TransaksiService] Response body: ${response.body}');
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Gagal menambah transaksi');
      }
    } else {
      // Kirim JSON biasa
      print('[TransaksiService] Body: ${json.encode(transaksi.toJson())}');
      final response = await _apiClient.post(
        '',
        transaksi.toJson(),
        context,
      );
      print('[TransaksiService] Response status: ${response.statusCode}');
      print('[TransaksiService] Response body: ${response.body}');
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Gagal menambah transaksi');
      }
    }
  }

  static Future<void> update(
      TransaksiModel transaksi, BuildContext context) async {
    if (transaksi.id == null) throw Exception('ID transaksi tidak boleh null');
    final endpoint = '${transaksi.id}';
    print('[TransaksiService] Request PUT ke ${_apiClient.baseUrl}/$endpoint');
    print('[TransaksiService] Body: ${json.encode(transaksi.toJson())}');
    final response = await _apiClient.put(
      endpoint,
      transaksi.toJson(),
      context,
    );

    print('[TransaksiService] Response status: ${response.statusCode}');
    print('[TransaksiService] Response body: ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Gagal mengupdate transaksi');
    }
  }

  static Future<void> delete(int id, BuildContext context) async {
    final endpoint = '$id';
    print(
        '[TransaksiService] Request DELETE ke ${_apiClient.baseUrl}/$endpoint');
    final response = await _apiClient.delete(endpoint, context);

    print('[TransaksiService] Response status: ${response.statusCode}');
    print('[TransaksiService] Response body: ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus transaksi');
    }
  }
}
