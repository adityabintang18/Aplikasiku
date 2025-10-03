import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:aplikasiku/models/model.dart';
import 'api_client.dart';

class NotesService {
  final ApiClient _api;

  NotesService({required String baseUrl}) : _api = ApiClient(baseUrl: baseUrl);

  Future<List<Note>> fetchNotes(BuildContext context) async {
    final response = await _api.get('catatan/', context);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      if (body['status'] == 'success' && body['data'] != null) {
        final List<dynamic> data = body['data'];
        return data.map<Note>((item) => Note.fromJson(item)).toList();
      }
    }
    throw Exception('Gagal memuat catatan');
  }

  Future<Note?> addNote(String note, String judul, BuildContext context,
      {String? tanggalCatatan}) async {
    final body = {
      'content': note,
      'judul': judul,
      'tanggal_catatan':
          tanggalCatatan ?? DateTime.now().toIso8601String().substring(0, 10),
    };

    final response = await _api.post('catatan/', body, context);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> resp = json.decode(response.body);
      if (resp['status'] == 'success' && resp['data'] != null) {
        return Note.fromJson(resp['data']);
      }
    }
    throw Exception('Gagal menambah catatan');
  }

  Future<Note?> editNote(int id, String content, BuildContext context,
      {String? judul, String? tanggalCatatan}) async {
    final body = {'content': content};
    if (judul != null) body['judul'] = judul;
    if (tanggalCatatan != null) body['tanggal_catatan'] = tanggalCatatan;

    final response = await _api.put('catatan/$id', body, context);

    if (response.statusCode == 200) {
      final Map<String, dynamic> resp = json.decode(response.body);
      if (resp['status'] == 'success' && resp['data'] != null) {
        return Note.fromJson(resp['data']);
      }
    }
    throw Exception('Gagal mengedit catatan');
  }

  Future<void> deleteNote(int id, BuildContext context) async {
    final response = await _api.delete('catatan/$id', context);

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus catatan');
    }
  }
}
