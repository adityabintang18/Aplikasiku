import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasiku/controllers/category_financial_controller.dart';
import 'package:aplikasiku/models/model.dart';
import 'package:aplikasiku/services/transaksi_service.dart';
import 'ringkasan_item.dart';
import 'transaction_detail_bottomsheet.dart';
// import 'add_transaction_bottomsheet.dart';

class ListViewHarian extends StatefulWidget {
  final DateTime selectedDate;

  const ListViewHarian({
    Key? key,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<ListViewHarian> createState() => _ListViewHarianState();
}

class _ListViewHarianState extends State<ListViewHarian> {
  final Map<int, bool> _expandedDays = {};
  List<TransaksiModel> _transaksi = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    final kategoriId = CategoryFinancialController.selectedCategoryId.value;
    debugPrint(
        'INIT: kategoriId yang dipilih saat halaman dibuka = $kategoriId');

    CategoryFinancialController.selectedCategoryId.addListener(_loadTransaksi);
    _loadTransaksi();
  }

  @override
  void didUpdateWidget(covariant ListViewHarian oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _loadTransaksi();
    }
  }

  @override
  void dispose() {
    CategoryFinancialController.selectedCategoryId
        .removeListener(_loadTransaksi);
    super.dispose();
  }

  Future<void> _loadTransaksi() async {
    setState(() => _loading = true);

    final kategoriId = CategoryFinancialController.selectedCategoryId.value;

    List<TransaksiModel> data = [];
    if (kategoriId == null) {
      data = await TransaksiService.getByMonth(widget.selectedDate, context);
    } else {
      data = await TransaksiService.getByJenisKategori(
          kategoriId.toString(), context);

      data = data
          .where((t) =>
              t.date.month == widget.selectedDate.month &&
              t.date.year == widget.selectedDate.year)
          .toList();
    }

    setState(() {
      _transaksi = data;
      _loading = false;
    });
  }

  String _monthName(int month) {
    const bulan = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    return bulan[month - 1];
  }

  String _dayName(int day) {
    final date =
        DateTime(widget.selectedDate.year, widget.selectedDate.month, day);
    const hari = [
      "Senin",
      "Selasa",
      "Rabu",
      "Kamis",
      "Jumat",
      "Sabtu",
      "Minggu"
    ];
    return hari[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: CategoryFinancialController.selectedCategoryId,
      builder: (context, kategoriId, _) {
        if (_loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_transaksi.isEmpty) {
          return Center(
            child: Text(
              "Belum ada transaksi bulan ini",
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          );
        }
        return _buildListView();
      },
    );
  }

  Widget _buildListView() {
    final Map<int, List<TransaksiModel>> groupedByDay = {};
    for (var item in _transaksi) {
      final day = item.date.day;
      if (!groupedByDay.containsKey(day)) {
        groupedByDay[day] = [];
      }
      groupedByDay[day]!.add(item);
    }
    final List<int> sortedDays = groupedByDay.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 12),
      itemCount: sortedDays.length,
      itemBuilder: (context, dayIndex) {
        final day = sortedDays[dayIndex];
        final items = groupedByDay[day]!;

        int totalIncome = 0;
        int totalExpense = 0;
        for (var item in items) {
          if (item.isIncome) {
            totalIncome += item.amount;
          } else {
            totalExpense += item.amount;
          }
        }

        final isExpanded = _expandedDays[day] ?? false;

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(10.0),
                onTap: () {
                  setState(() {
                    _expandedDays[day] = !(isExpanded);
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${_dayName(day)}, $day ${_monthName(widget.selectedDate.month)} ${widget.selectedDate.year}",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.deepPurpleAccent,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                RingkasanItem(
                                  label: "Pemasukan",
                                  value: "+Rp ${_formatRupiah(totalIncome)}",
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 16),
                                RingkasanItem(
                                  label: "Pengeluaran",
                                  value: "-Rp ${_formatRupiah(totalExpense)}",
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.deepPurpleAccent,
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    children: [
                      for (int i = 0; i < items.length; i++) ...[
                        ListTile(
                          dense: true,
                          visualDensity:
                              const VisualDensity(horizontal: 0, vertical: -2),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 4.0),
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: items[i].isIncome
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            child: Icon(
                              items[i].isIncome
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color:
                                  items[i].isIncome ? Colors.green : Colors.red,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            items[i].title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'Kategori: ${items[i].nameCategory ?? '-'}',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            "${items[i].isIncome ? '+' : '-'}Rp ${_formatRupiah(items[i].amount)}",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color:
                                  items[i].isIncome ? Colors.green : Colors.red,
                            ),
                          ),
                          onTap: () async {
                            final result =
                                await showTransactionDetailBottomSheet(
                              context,
                              items[i],
                            );
                            if (result == true) {
                              _loadTransaksi();
                            }
                          },
                        ),
                        if (i < items.length - 1)
                          const Divider(height: 4, indent: 56, endIndent: 12),
                      ]
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static String _formatRupiah(int value) {
    final str = value.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }
}
