import 'dart:convert';
import 'package:aplikasiku/models/model.dart';
import 'package:flutter/material.dart';
import 'package:aplikasiku/services/api_client.dart';

class RefService {
  static final ApiClient _api = ApiClient(baseUrl: "http://192.168.1.10:8000");

  static Future<List<JenisTransaksiModel>> getJenisTransaksi(
      BuildContext context) async {
    debugPrint('[RefService] Memulai request GET ref/jenis');
    final response = await _api.get("ref/jenis", context);
    debugPrint('[RefService] Status code: ${response.statusCode}');
    debugPrint('[RefService] Response body: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        try {
          final result = data.map((e) {
            if (e is Map && e.containsKey('id')) {
              return JenisTransaksiModel.fromJson(Map<String, dynamic>.from(e));
            } else {
              debugPrint(
                  '[RefService] Data jenis transaksi tidak memiliki id: $e');
              throw Exception("Data jenis transaksi tidak memiliki id");
            }
          }).toList();
          debugPrint(
              '[RefService] Berhasil parsing data jenis transaksi (${result.length} item)');
          return result;
        } catch (e) {
          debugPrint('[RefService] Gagal parsing data jenis transaksi: $e');
          throw Exception("Gagal parsing data jenis transaksi: $e");
        }
      } else {
        debugPrint('[RefService] Format data tidak sesuai (bukan List): $data');
        throw Exception("Format data tidak sesuai (bukan List)");
      }
    } else {
      debugPrint(
          '[RefService] Gagal mengambil data jenis transaksi (${response.statusCode}): ${response.body}');
      throw Exception(
          "Gagal mengambil data jenis transaksi (${response.statusCode})");
    }
  }

  /// Menambah jenis transaksi baru ke API, sekarang dengan jenisKategori.
  static Future<bool> addJenisTransaksi(BuildContext context, String nama,
      String icon, String jenisKategori) async {
    debugPrint('[RefService] Memulai request POST ref/jenis');
    debugPrint(
        '[RefService] Data yang dikirim: nama=$nama, icon=$icon, jenisKategori=$jenisKategori');
    final response = await _api.post(
        "ref/jenis",
        {
          "nama": nama,
          "icon": icon,
          "jenisKategori": jenisKategori,
        },
        context);

    debugPrint('[RefService] Status code: ${response.statusCode}');
    debugPrint('[RefService] Response body: ${response.body}');
    if (response.statusCode == 201) {
      debugPrint('[RefService] Berhasil menambah jenis transaksi');
      return true;
    } else {
      debugPrint('[RefService] Gagal menambah jenis transaksi');
      // Bisa menambahkan logika error handling lebih detail di sini jika perlu
      return false;
    }
  }

  static Future<List<KategoriModel>> getKategori(BuildContext context) async {
    debugPrint('[RefService] Memulai request GET ref/kategori');
    final response = await _api.get("ref/kategori", context);
    debugPrint('[RefService] Status code: ${response.statusCode}');
    debugPrint('[RefService] Response body: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        try {
          final result = data.map((e) {
            if (e is Map && e.containsKey('id')) {
              return KategoriModel.fromJson(Map<String, dynamic>.from(e));
            } else {
              debugPrint('[RefService] Data kategori tidak memiliki id: $e');
              throw Exception("Data kategori tidak memiliki id");
            }
          }).toList();
          debugPrint(
              '[RefService] Berhasil parsing data kategori (${result.length} item)');
          return result;
        } catch (e) {
          debugPrint('[RefService] Gagal parsing data kategori: $e');
          throw Exception("Gagal parsing data kategori: $e");
        }
      } else {
        debugPrint(
            '[RefService] Format data kategori tidak sesuai (bukan List): $data');
        throw Exception("Format data kategori tidak sesuai (bukan List)");
      }
    } else {
      debugPrint(
          '[RefService] Gagal mengambil data kategori (${response.statusCode}): ${response.body}');
      throw Exception("Gagal mengambil data kategori (${response.statusCode})");
    }
  }
}
