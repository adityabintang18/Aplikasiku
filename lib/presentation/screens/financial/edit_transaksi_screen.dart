import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';


import '../../../controllers/add_transaction_controller.dart';

class EditTransaksiScreen extends StatefulWidget {
  final Map<String, dynamic>? transaksi;

  const EditTransaksiScreen({Key? key, this.transaksi}) : super(key: key);

  @override
  State<EditTransaksiScreen> createState() => _EditTransaksiScreenState();
}

class _EditTransaksiScreenState extends State<EditTransaksiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _nominalController = TextEditingController();
  final _keteranganController = TextEditingController();

  String? _jenisTransaksi;
  String? _kategori;
  DateTime _tanggal = DateTime.now();

  final List<String> _kategoriPemasukan = [
    'gaji',
    'bonus',
    'investasi',
    'bisnis',
    'hadiah',
    'lainnya'
  ];

  final List<String> _kategoriPengeluaran = [
    'makanan',
    'transportasi',
    'belanja',
    'tagihan',
    'hiburan',
    'kesehatan',
    'pendidikan',
    'lainnya'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.transaksi != null) {
      _ambilJenisDanKategoriDariTransaksi(widget.transaksi!);
    } else {
      _jenisTransaksi = 'pemasukan';
      _kategori = 'lainnya';
    }
  }

  void _ambilJenisDanKategoriDariTransaksi(Map<String, dynamic> transaksi) {
    _judulController.text = transaksi['judul'] ?? '';
    _nominalController.text = transaksi['nominal']?.toString() ?? '';
    _keteranganController.text = transaksi['keterangan'] ?? '';

    // default jenis
    _jenisTransaksi = transaksi['jenis'] ?? 'pemasukan';

    // ambil kategori sesuai jenis
    if (_jenisTransaksi == 'pemasukan') {
      final listKategori = _kategoriPemasukan;
      _kategori = listKategori.contains(transaksi['kategori'])
          ? transaksi['kategori']
          : 'lainnya';
    } else if (_jenisTransaksi == 'pengeluaran') {
      final listKategori = _kategoriPengeluaran;
      _kategori = listKategori.contains(transaksi['kategori'])
          ? transaksi['kategori']
          : 'lainnya';
    } else {
      _kategori = 'lainnya';
    }

    // ambil tanggal
    if (transaksi['tanggal'] != null) {
      _tanggal = DateTime.tryParse(transaksi['tanggal']) ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _nominalController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.deepPurpleAccent;
    final Color secondaryColor = Colors.deepPurple.shade50;
    final Color cardColor = Colors.white;
    final Color borderColor = Colors.deepPurpleAccent.withOpacity(0.2);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaksi != null ? 'Edit Transaksi' : 'Tambah Transaksi',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, secondaryColor],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormCard(primaryColor, cardColor, borderColor),
                      const SizedBox(height: 28),
                      _buildActionButtons(primaryColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(
      Color primaryColor, Color cardColor, Color borderColor) {
    return Card(
      color: cardColor,
      elevation: 10,
      shadowColor: primaryColor.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: borderColor, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 26.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Informasi Transaksi', primaryColor),
            const SizedBox(height: 22),
            _buildJudulField(primaryColor),
            const SizedBox(height: 18),
            _buildNominalField(primaryColor),
            const SizedBox(height: 18),
            _buildJenisTransaksiField(primaryColor),
            const SizedBox(height: 18),
            _buildKategoriField(primaryColor),
            const SizedBox(height: 18),
            _buildTanggalField(primaryColor),
            const SizedBox(height: 18),
            _buildKeteranganField(primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Icon(Icons.info_outline, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildJudulField(Color primaryColor) {
    return TextFormField(
      controller: _judulController,
      decoration: InputDecoration(
        labelText: 'Judul Transaksi',
        hintText: 'Masukkan judul transaksi',
        prefixIcon: Icon(Icons.title, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.deepPurple.shade50.withOpacity(0.2),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Judul transaksi wajib diisi';
        }
        return null;
      },
    );
  }

  Widget _buildNominalField(Color primaryColor) {
    return TextFormField(
      controller: _nominalController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Nominal',
        hintText: 'Masukkan nominal transaksi',
        prefixIcon: Icon(Icons.attach_money, color: primaryColor),
        prefixText: 'Rp ',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.deepPurple.shade50.withOpacity(0.2),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Nominal wajib diisi';
        }
        if (int.tryParse(value) == null || int.parse(value) <= 0) {
          return 'Nominal harus berupa angka positif';
        }
        return null;
      },
    );
  }

  Widget _buildJenisTransaksiField(Color primaryColor) {
    return Consumer<AddTransactionController>(
      builder: (context, controller, _) {
        if (controller.jenisKategoriLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.jenisKategoriError != null) {
          return Text(controller.jenisKategoriError!,
              style: const TextStyle(color: Colors.red));
        }

        return DropdownButtonFormField<int>(
          value: controller.selectedJenisKategoriId,
          decoration: InputDecoration(
            labelText: 'Jenis Transaksi',
            prefixIcon: Icon(Icons.swap_vert, color: primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            filled: true,
            fillColor: Colors.deepPurple.shade50.withOpacity(0.2),
          ),
          items: controller.jenisKategoriList.map((j) {
            return DropdownMenuItem<int>(
              value: j.id,
              child: Text(j.nama ?? ""),
            );
          }).toList(),
          onChanged: (val) {
            controller.setSelectedJenisKategori(val);
          },
        );
      },
    );
  }

  Widget _buildKategoriField(Color primaryColor) {
    return Consumer<AddTransactionController>(
      builder: (context, controller, _) {
        final kategoriList = controller.filteredKategoriList;

        return DropdownButtonFormField<int>(
          value: controller.selectedCategoryId,
          decoration: InputDecoration(
            labelText: 'Kategori',
            prefixIcon: Icon(Icons.category, color: primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            filled: true,
            fillColor: Colors.deepPurple.shade50.withOpacity(0.2),
          ),
          items: kategoriList.map((k) {
            return DropdownMenuItem<int>(
              value: k.id,
              child: Text(k.nama ?? ""),
            );
          }).toList(),
          onChanged: (val) {
            controller.setSelectedCategory(val);
          },
        );
      },
    );
  }

  Widget _buildTanggalField(Color primaryColor) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50.withOpacity(0.2),
          border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: primaryColor),
            const SizedBox(width: 12),
            Text(
              'Tanggal: ${_tanggal.day.toString().padLeft(2, '0')}/${_tanggal.month.toString().padLeft(2, '0')}/${_tanggal.year}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildKeteranganField(Color primaryColor) {
    return TextFormField(
      controller: _keteranganController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Keterangan (Opsional)',
        hintText: 'Tambahkan keterangan transaksi',
        prefixIcon: Icon(Icons.note, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.deepPurple.shade50.withOpacity(0.2),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildActionButtons(Color primaryColor) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close,
                size: 18, color: Colors.deepPurpleAccent),
            label: const Text(
              'Batal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.deepPurpleAccent,
              side: const BorderSide(color: Colors.deepPurpleAccent),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveTransaksi,
            icon: Icon(
              widget.transaksi != null ? Icons.save : Icons.add,
              size: 18,
              color: Colors.white,
            ),
            label: Text(
              widget.transaksi != null ? 'Update' : 'Simpan',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurpleAccent,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _tanggal) {
      setState(() {
        _tanggal = picked;
      });
    }
  }

  void _saveTransaksi() {
    final controller = context.read<AddTransactionController>();
    controller.saveTransaction(context);
  }
}
