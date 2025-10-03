import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:aplikasiku/controllers/add_transaction_controller.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NominalInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('id');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove all non-digit characters
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Format the number
    String formatted = _formatter.format(int.parse(newText));

    // Calculate the new cursor position
    int selectionIndex =
        formatted.length - (oldValue.text.length - oldValue.selection.end);

    if (selectionIndex < 0) selectionIndex = 0;
    if (selectionIndex > formatted.length) selectionIndex = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

Future<bool?> showAddTransactionBottomSheet(
    BuildContext context, DateTime selectedDate) {
  debugPrint(
      "DEBUG: showAddTransactionBottomSheet dipanggil, date = $selectedDate");

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      debugPrint("DEBUG: BottomSheet builder dijalankan");
      return ChangeNotifierProvider(
        create: (_) {
          debugPrint("DEBUG: AddTransactionController dibuat");
          return AddTransactionController()
            ..selectedDate = selectedDate
            ..fetchJenisKategori(context)
            ..fetchKategori(context);
        },
        child: _AddTransactionBottomSheet(
          initialDate: selectedDate,
        ),
      );
    },
  );
}

class _AddTransactionBottomSheet extends StatefulWidget {
  final DateTime? initialDate;
  const _AddTransactionBottomSheet({super.key, this.initialDate});

  @override
  State<_AddTransactionBottomSheet> createState() =>
      _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState
    extends State<_AddTransactionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _nominalController = TextEditingController();
  final _catatanController = TextEditingController();
  File? _selectedImage;

  late DateTime _selectedDate;
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy', 'id');

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _judulController.dispose();
    _nominalController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required ImageSource source}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
      final c = context.read<AddTransactionController>();
      c.setFoto(_selectedImage);
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(source: ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      final c = context.read<AddTransactionController>();
      c.setSelectedDate(picked);
    }
  }

  Future<void> _handleSaveTransaction(AddTransactionController c) async {
    if (_formKey.currentState?.validate() ?? false) {
      c.setJudul(_judulController.text);
      c.setNominal(_nominalController.text);
      c.setCatatan(_catatanController.text);
      c.setFoto(_selectedImage);
      c.setSelectedDate(_selectedDate);

      // saveTransaction bisa async, jadi kita tunggu hasilnya
      bool result = await c.saveTransaction(context);

      if (result) {
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Transaksi berhasil ditambahkan",
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AddTransactionController>();

    if (c.jenisKategoriLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (c.jenisKategoriError != null) {
      return Center(child: Text(c.jenisKategoriError!));
    }

    final viewInsets = MediaQuery.of(context).viewInsets;
    final bottomPadding = viewInsets.bottom;

    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          left: 0,
          right: 0,
          top: 0,
          bottom: bottomPadding,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            // Agar scroll mengikuti keyboard, tambahkan physics dan shrinkWrap
            physics: const ClampingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 18),
                    // decoration: BoxDecoration(
                    //   color: Colors.grey[300],
                    //   borderRadius: BorderRadius.circular(8),
                    // ),
                  ),
                  Text(
                    "Tambah Transaksi",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6C5CE7),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 0. Tipe Transaksi (Pemasukan/Pengeluaran)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tipe Transaksi',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Pemasukan'),
                        selected: c.isIncome == true,
                        selectedColor: Colors.green.shade100,
                        labelStyle: GoogleFonts.poppins(
                          color: c.isIncome ? Colors.green : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (sel) {
                          c.setIsIncome(true);
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Pengeluaran'),
                        selected: c.isIncome == false,
                        selectedColor: Colors.red.shade100,
                        labelStyle: GoogleFonts.poppins(
                          color: c.isIncome ? Colors.black87 : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (sel) {
                          c.setIsIncome(false);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 1. Jenis Transaksi
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonFormField<int>(
                      value: c.jenisKategoriList
                              .any((e) => e.id == c.selectedJenisKategoriId)
                          ? c.selectedJenisKategoriId
                          : null,
                      items: c.jenisKategoriList
                          .map((e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(
                                e.nama,
                                style: GoogleFonts.poppins(fontSize: 15),
                              )))
                          .toList(),
                      onChanged: (val) {
                        debugPrint("DEBUG: User pilih kategori id=$val");
                        c.setSelectedJenisKategori(val);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Jenis Transaksi',
                        border: InputBorder.none,
                      ),
                      style: GoogleFonts.poppins(
                          fontSize: 15, color: Colors.black87),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      dropdownColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. Kategori Transaksi
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonFormField<int>(
                      value: c.filteredKategoriList
                              .any((e) => e.id == c.selectedCategoryId)
                          ? c.selectedCategoryId
                          : null,
                      items: c.filteredKategoriList
                          .map((e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(
                                  e.nama,
                                  style: GoogleFonts.poppins(fontSize: 15),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        c.setSelectedCategory(val);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Kategori Transaksi',
                        border: InputBorder.none,
                      ),
                      style: GoogleFonts.poppins(
                          fontSize: 15, color: Colors.black87),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      dropdownColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Tanggal",
                          prefixIcon: const Icon(Icons.date_range_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        style: GoogleFonts.poppins(fontSize: 15),
                        controller: TextEditingController(
                          text: _dateFormat.format(_selectedDate),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Tanggal wajib diisi";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. Judul Transaksi
                  TextFormField(
                    controller: _judulController,
                    decoration: InputDecoration(
                      labelText: "Judul Transaksi",
                      prefixIcon: const Icon(Icons.title_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    style: GoogleFonts.poppins(fontSize: 15),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "Judul transaksi wajib diisi";
                      }
                      return null;
                    },
                    onChanged: (val) {
                      c.setJudul(val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // 4. Nominal Transaksi
                  TextFormField(
                    controller: _nominalController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      NominalInputFormatter(),
                    ],
                    decoration: InputDecoration(
                      labelText: "Nominal (Rp)",
                      prefixIcon: const Icon(Icons.attach_money_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    style: GoogleFonts.poppins(fontSize: 15),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "Nominal wajib diisi";
                      }
                      if (int.tryParse(
                              val.replaceAll('.', '').replaceAll(',', '')) ==
                          null) {
                        return "Nominal tidak valid";
                      }
                      return null;
                    },
                    onChanged: (val) {
                      c.setNominal(val);
                    },
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _catatanController,
                    decoration: InputDecoration(
                      labelText: "Catatan (opsional)",
                      prefixIcon: const Icon(Icons.note_alt_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    style: GoogleFonts.poppins(fontSize: 15),
                    maxLines: 2,
                    onChanged: (val) {
                      c.setCatatan(val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // 6. Input Foto (kamera/galeri)
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _showImageSourceActionSheet,
                        icon: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white),
                        label: Text(
                          _selectedImage == null ? "Tambah Foto" : "Ganti Foto",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C5CE7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                      ),
                      const SizedBox(width: 14),
                      if (_selectedImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: c.isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.2,
                              ),
                            )
                          : const Icon(Icons.save_rounded, color: Colors.white),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          c.isSaving ? "Menyimpan..." : "Simpan Transaksi",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      onPressed: c.isSaving
                          ? null
                          : () {
                              _handleSaveTransaction(c);
                            },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
