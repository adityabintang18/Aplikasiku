import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:aplikasiku/models/model.dart';
import 'api_client.dart';

class CalenderLiturgicalService {
  final ApiClient _api;

  CalenderLiturgicalService({required String baseUrl})
      : _api = ApiClient(baseUrl: baseUrl);

  List<List<CalendarDay>> parseCalendar(dynamic raw) {
    if (raw is! List) return [];
    return raw.map<List<CalendarDay>>((week) {
      if (week is! List) return [];
      return week.where((day) => day != null).map((day) {
        return CalendarDay.fromJson(day);
      }).toList();
    }).toList();
  }

  Future<List<List<CalendarDay>>> fetchKalender(
    BuildContext context, {
    int? bulan,
    int? tahun,
  }) async {
    final now = DateTime.now();
    final bln = bulan ?? now.month;
    final thn = tahun ?? now.year;

    final response = await _api.get('kalender?bulan=$bln&tahun=$thn', context);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return parseCalendar(data['calendar']);
    } else {
      throw Exception('Gagal memuat kalender, status: ${response.statusCode}');
    }
  }

  Future<CalendarDay?> fetchKalenderHariIni(BuildContext context) async {
    final now = DateTime.now();
    final response = await _api.get(
      'kalender?bulan=${now.month}&tahun=${now.year}',
      context,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<List<CalendarDay>> kalender = parseCalendar(data['calendar']);

      for (final week in kalender) {
        for (final day in week) {
          final raw = day.tanggal.trim();

          if (int.tryParse(raw) == now.day) return day;

          try {
            final parsed = DateTime.tryParse(_parseTanggalLengkap(raw));
            if (parsed != null &&
                parsed.year == now.year &&
                parsed.month == now.month &&
                parsed.day == now.day) {
              return day;
            }
          } catch (e) {
            // abaikan error parsing
          }
        }
      }
      return null;
    } else {
      throw Exception('Gagal memuat kalender, status: ${response.statusCode}');
    }
  }

  String _parseTanggalLengkap(String raw) {
    final bulanMap = {
      'Januari': '01',
      'Februari': '02',
      'Maret': '03',
      'April': '04',
      'Mei': '05',
      'Juni': '06',
      'Juli': '07',
      'Agustus': '08',
      'September': '09',
      'Oktober': '10',
      'November': '11',
      'Desember': '12',
    };

    final parts = raw.split(' ');
    if (parts.length == 3) {
      final day = parts[0].padLeft(2, '0');
      final month = bulanMap[parts[1]] ?? '01';
      final year = parts[2];
      return "$year-$month-$day";
    }
    return raw;
  }

  Future<List<LiturgicalModel>> fetchAyat(
    BuildContext context,
    String q,
  ) async {
    final response = await _api.get('kalender/alkitab?q=$q', context);

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat ayat, status: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded.map((e) => LiturgicalModel.fromJson(e)).toList();
    }

    if (decoded is Map<String, dynamic>) {
      if (decoded.containsKey('isi') && decoded['isi'] is List) {
        return (decoded['isi'] as List)
            .map(
                (e) => LiturgicalModel(text: e.toString(), href: '', param: ''))
            .toList();
      }

      if (decoded.containsKey('text') ||
          decoded.containsKey('href') ||
          decoded.containsKey('param')) {
        return [LiturgicalModel.fromJson(decoded)];
      }

      return [LiturgicalModel(text: decoded.toString(), href: '', param: '')];
    }

    return [];
  }
}
