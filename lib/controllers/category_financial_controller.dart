import 'package:flutter/material.dart';

class CategoryFinancialController {
  // Notifier untuk kategori yang dipilih (string, bisa nama/label)
  static final ValueNotifier<String> selectedCategory =
      ValueNotifier<String>('');

  // Notifier untuk id kategori numerik (untuk filter, dsb)
  static final ValueNotifier<int?> selectedCategoryId =
      ValueNotifier<int?>(null);

  // Notifier untuk nama kategori yang dipilih (label user-friendly)
  static final ValueNotifier<String> selectedCategoryName =
      ValueNotifier<String>('');

  // Notifier untuk status expand/collapse header kategori
  static final ValueNotifier<bool> isExpanded = ValueNotifier<bool>(false);

  // Notifier untuk tanggal/bulan yang dipilih (sinkron dengan Financial)
  static final ValueNotifier<DateTime> selectedDate =
      ValueNotifier<DateTime>(DateTime.now());

  /// Pilih kategori berdasarkan id, string kategori, dan nama label
  static void selectCategory({
    int? id,
    required String category,
    required String name,
  }) {
    selectedCategoryId.value = id;
    selectedCategory.value = category;
    selectedCategoryName.value = name;
  }

  // Fungsi untuk memilih kategori hanya berdasarkan string (misal 'Semua' atau '')
  static void selectCategoryString(String category) {
    selectedCategory.value = category;
    selectedCategoryId.value = null;
    selectedCategoryName.value = category;
  }

  // Fungsi untuk reset pilihan kategori
  static void clearSelection() {
    selectedCategory.value = '';
    selectedCategoryId.value = null;
    selectedCategoryName.value = '';
  }
}
