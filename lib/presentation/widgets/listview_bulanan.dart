import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasiku/services/transaksi_service.dart';
import 'package:aplikasiku/controllers/category_financial_controller.dart';

class ListViewBulanan extends StatefulWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>>? monthlyData;

  const ListViewBulanan({
    Key? key,
    required this.selectedDate,
    this.monthlyData,
  }) : super(key: key);

  @override
  State<ListViewBulanan> createState() => _ListViewBulananState();
}

class _ListViewBulananState extends State<ListViewBulanan> {
  List<Map<String, dynamic>> _data = [];
  bool _loading = true;
  int? _expandedIndex;
  int? _selectedJenisKategoriId; // cache untuk trigger

  int get _totalAmountAll {
    int total = 0;
    for (final item in _data) {
      total += (item['totalAmount'] ?? 0) as int;
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    // dengarkan perubahan filter jenis_kategori
    _selectedJenisKategoriId = null;
    CategoryFinancialController.selectedCategoryId.addListener(_onFilterChanged);
    _load();
  }

  @override
  void didUpdateWidget(covariant ListViewBulanan oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _load();
    }
  }

  void _onFilterChanged() {
    // jika jenis kategori berubah, reload
    final currentJenis = CategoryFinancialController.selectedCategoryId.value;
    if (_selectedJenisKategoriId != currentJenis) {
      _selectedJenisKategoriId = currentJenis;
      _load();
    }
  }

  @override
  void dispose() {
    CategoryFinancialController.selectedCategoryId.removeListener(_onFilterChanged);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      if (widget.monthlyData != null) {
        _data = widget.monthlyData!;
      } else {
        final jenisId = CategoryFinancialController.selectedCategoryId.value;
        _data = await TransaksiService.getMonthlySummary(
          widget.selectedDate,
          context,
          jenisKategori: jenisId,
        );
      }
    } catch (_) {
      _data = [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final data = _data;
    final totalAmount = _totalAmountAll;

    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_chart_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Belum ada ringkasan transaksi',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Data tidak ditemukan untuk bulan ini',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = data[index];
        final isIncome = (item['income'] ?? 0) > (item['expense'] ?? 0);
        final int totalAmountKategori = (item['totalAmount'] ?? 0) as int;
        final double percent =
            totalAmount == 0 ? 0 : (totalAmountKategori / totalAmount * 100);
        final bool expanded = _expandedIndex == index;

        return GestureDetector(
          onLongPress: () {
            setState(() {
              _expandedIndex = expanded ? null : index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: isIncome
                        ? Colors.green.withOpacity(0.12)
                        : Colors.red.withOpacity(0.12),
                    child: Icon(
                      Icons.category,
                      color: isIncome ? Colors.green : Colors.red,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    (item['nameCategory'] ?? 'Tanpa Kategori').toString(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      "${item['transactionCount'] ?? 0} transaksi",
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rp ${_formatRupiah((item['totalAmount'] ?? 0) as int)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_downward,
                              size: 13, color: Colors.red.shade400),
                          Text(
                            ' ${_formatRupiah((item['expense'] ?? 0) as int)}',
                            style: GoogleFonts.poppins(
                              color: Colors.red.shade400,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_upward,
                              size: 13, color: Colors.green.shade400),
                          Text(
                            ' ${_formatRupiah((item['income'] ?? 0) as int)}',
                            style: GoogleFonts.poppins(
                              color: Colors.green.shade400,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Persentase bar dan label
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: percent / 100,
                              child: Container(
                                height: 16,
                                decoration: BoxDecoration(
                                  color: isIncome
                                      ? Colors.green.withOpacity(0.7)
                                      : Colors.red.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${percent.toStringAsFixed(1)}%",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                // Expandable detail jika diklik long press
                if (expanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(),
                        Text(
                          "Detail Kategori",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.category,
                                size: 18, color: Colors.blueGrey),
                            const SizedBox(width: 6),
                            Text(
                              (item['nameCategory'] ?? 'Tanpa Kategori')
                                  .toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.swap_vert,
                                size: 18, color: Colors.orange),
                            const SizedBox(width: 6),
                            Text(
                              "Transaksi: ${item['transactionCount'] ?? 0}",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.attach_money,
                                size: 18, color: Colors.green),
                            const SizedBox(width: 6),
                            Text(
                              "Pemasukan: Rp ${_formatRupiah((item['income'] ?? 0) as int)}",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.money_off, size: 18, color: Colors.red),
                            const SizedBox(width: 6),
                            Text(
                              "Pengeluaran: Rp ${_formatRupiah((item['expense'] ?? 0) as int)}",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.percent, size: 18, color: Colors.blue),
                            const SizedBox(width: 6),
                            Text(
                              "Persentase: ${percent.toStringAsFixed(2)}%",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatRupiah(int value) {
    if (value == 0) return '0';
    final str = value.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }
}
