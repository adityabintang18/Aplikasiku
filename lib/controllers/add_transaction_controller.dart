import 'dart:io';
import 'package:flutter/material.dart';
import 'package:aplikasiku/models/model.dart';
import 'package:aplikasiku/services/transaksi_service.dart';
import 'package:aplikasiku/services/ref_jenis_transaksi.dart';

class AddTransactionController extends ChangeNotifier {
  // Controller untuk input judul, nominal, dan catatan
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  // State untuk income/saving
  bool isIncome = false;
  bool isSaving = false;

  // State untuk pilihan kategori dan jenis
  int? selectedJenisKategoriId;
  String? selectedJenisKategoriNama;
  int? selectedCategoryId;
  String? selectedCategoryNama;
  DateTime selectedDate = DateTime.now();
  File? selectedImage;

  // List kategori/jenis dan state loading/error
  List<JenisTransaksiModel> jenisKategoriList = [];
  List<KategoriModel> kategoriList = [];
  List<KategoriModel> get filteredKategoriList {
    if (kategoriList.isEmpty) return [];
    final keyword = isIncome ? 'pemasukan' : 'pengeluaran';
    return kategoriList
        .where((k) =>
            (k.deskripsi ?? '').toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }

  bool jenisKategoriLoading = true;
  String? jenisKategoriError;

  // Ambil data jenis/kategori dari service
  Future<void> fetchJenisKategori(BuildContext context) async {
    debugPrint("DEBUG: fetchJenisKategori() dipanggil...");
    jenisKategoriLoading = true;
    jenisKategoriError = null;
    notifyListeners();

    try {
      final data = await RefService.getJenisTransaksi(context);
      debugPrint("DEBUG: Data kategori berhasil diambil, total=${data.length}");
      jenisKategoriList = data;

      if (jenisKategoriList.isNotEmpty) {
        selectedJenisKategoriId = jenisKategoriList.first.id;
        selectedJenisKategoriNama = jenisKategoriList.first.nama;
        selectedCategoryId = jenisKategoriList.first.id;
        selectedCategoryNama = jenisKategoriList.first.nama;
        debugPrint(
            "DEBUG: Default jenis dipilih => ID=$selectedJenisKategoriId, Nama=$selectedJenisKategoriNama");
        debugPrint(
            "DEBUG: Default kategori dipilih => ID=$selectedCategoryId, Nama=$selectedCategoryNama");
      }

      jenisKategoriLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("DEBUG: Gagal ambil kategori, error=$e");
      jenisKategoriError = "Gagal memuat kategori";
      jenisKategoriLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchKategori(BuildContext context) async {
    debugPrint("DEBUG: fetchKategori() dipanggil...");
    try {
      final data = await RefService.getKategori(context);
      debugPrint(
          "DEBUG: Data kategori transaksi berhasil diambil, total=${data.length}");
      kategoriList = data;
      if (kategoriList.isNotEmpty && selectedCategoryId == null) {
        selectedCategoryId = kategoriList.first.id;
        selectedCategoryNama = kategoriList.first.nama;
        debugPrint(
            "DEBUG: Default kategori transaksi dipilih => ID=$selectedCategoryId, Nama=$selectedCategoryNama");
      }
      notifyListeners();
    } catch (e) {
      debugPrint("DEBUG: Gagal ambil kategori transaksi, error=$e");
    }
  }

  // Setter untuk judul
  void setJudul(String? val) {
    if (val != null) titleController.text = val;
    notifyListeners();
  }

  // Setter untuk nominal
  void setNominal(String? val) {
    if (val != null) amountController.text = val;
    notifyListeners();
  }

  // Setter untuk catatan
  void setCatatan(String? val) {
    if (val != null) descriptionController.text = val;
    notifyListeners();
  }

  // Setter untuk foto
  void setFoto(File? file) {
    selectedImage = file;
    notifyListeners();
  }

  // Setter untuk tipe transaksi (pemasukan/pengeluaran)
  void setIsIncome(bool value) {
    isIncome = value;
    // reset pilihan kategori jika tidak sesuai filter
    final list = filteredKategoriList;
    if (list.isNotEmpty) {
      if (selectedCategoryId == null ||
          !list.any((k) => k.id == selectedCategoryId)) {
        selectedCategoryId = list.first.id;
        selectedCategoryNama = list.first.nama;
      }
    } else {
      selectedCategoryId = null;
      selectedCategoryNama = null;
    }
    notifyListeners();
  }

  // Setter untuk jenis kategori
  void setSelectedJenisKategori(int? id) {
    selectedJenisKategoriId = id;
    final found = id == null
        ? null
        : jenisKategoriList.firstWhere(
            (e) => e.id == id,
            orElse: () => jenisKategoriList.first,
          );
    selectedJenisKategoriNama = found?.nama;
    notifyListeners();
  }

  // Setter untuk kategori
  void setSelectedCategory(int? id) {
    selectedCategoryId = id;
    final list = filteredKategoriList;
    final found = id == null
        ? null
        : list.firstWhere(
            (e) => e.id == id,
            orElse: () => list.isNotEmpty ? list.first : null as KategoriModel,
          );
    selectedCategoryNama = found?.nama;
    notifyListeners();
  }

  // Setter untuk tanggal transaksi
  void setSelectedDate(DateTime? date) {
    if (date != null) {
      selectedDate = date;
      notifyListeners();
    }
  }

  // Simpan transaksi
  Future<bool> saveTransaction(BuildContext context) async {
    debugPrint("DEBUG: saveTransaction() dipanggil");

    // Validasi jenis kategori
    if (selectedJenisKategoriId == null) {
      debugPrint(
          "DEBUG: selectedJenisKategoriId null. Batalkan simpan dan tampilkan pesan.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih kategori terlebih dahulu.")),
      );
      return false;
    }

    // Validasi kategori
    if (selectedCategoryId == null) {
      debugPrint(
          "DEBUG: selectedCategoryId null. Batalkan simpan dan tampilkan pesan.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Pilih kategori transaksi terlebih dahulu.")),
      );
      return false;
    }

    // Validasi judul
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul transaksi wajib diisi.")),
      );
      return false;
    }

    // Validasi nominal
    final cleanAmount = amountController.text.replaceAll(RegExp(r'[^\d]'), '');
    final amount = int.tryParse(cleanAmount);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Nominal wajib diisi dan harus lebih dari 0.")),
      );
      return false;
    }

    isSaving = true;
    notifyListeners();

    try {
      debugPrint("DEBUG: Data transaksi yang akan disimpan:");
      debugPrint("  Judul       = ${titleController.text}");
      debugPrint("  Kategori ID = $selectedJenisKategoriId");
      debugPrint("  Kategori Nm = $selectedJenisKategoriNama");
      debugPrint("  Category ID = $selectedCategoryId");
      debugPrint("  Category Nm = $selectedCategoryNama");
      debugPrint("  Nominal     = $amount");
      debugPrint("  Income?     = $isIncome");
      debugPrint("  Tanggal     = $selectedDate");
      debugPrint("  Deskripsi   = ${descriptionController.text}");
      debugPrint("  Foto Path   = ${selectedImage?.path}");

      final transaksi = TransaksiModel(
        id: null,
        title: titleController.text,
        category: selectedCategoryId,
        jenisKategori: selectedJenisKategoriId,
        amount: amount,
        isIncome: isIncome,
        date: selectedDate,
        description: descriptionController.text,
        photoPath: selectedImage?.path,
      );

      await TransaksiService.add(transaksi, context);
      debugPrint("DEBUG: Transaksi berhasil dikirim ke service");

      // Tutup bottomsheet dan return true
      Navigator.pop(context, true);
      debugPrint("DEBUG: BottomSheet ditutup dengan hasil = true");
      return true;
    } catch (e) {
      debugPrint("DEBUG: Gagal simpan transaksi, error=$e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal simpan: $e")),
      );
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
      debugPrint("DEBUG: isSaving=false, UI diupdate");
    }
  }
}
