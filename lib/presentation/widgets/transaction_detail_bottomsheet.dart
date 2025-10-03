import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasiku/models/model.dart';
import 'package:aplikasiku/services/transaksi_service.dart';
import 'package:aplikasiku/presentation/screens/financial/edit_transaksi_screen.dart';

class TransactionDetailBottomSheet extends StatelessWidget {
  final TransaksiModel transaksi;

  const TransactionDetailBottomSheet({
    Key? key,
    required this.transaksi,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];

    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detail Transaksi',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: transaksi.isIncome
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: transaksi.isIncome
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: transaksi.isIncome
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        child: Icon(
                          transaksi.isIncome
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: transaksi.isIncome ? Colors.green : Colors.red,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaksi.isIncome ? 'PEMASUKAN' : 'PENGELUARAN',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: transaksi.isIncome
                                    ? Colors.green
                                    : Colors.red,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              transaksi.title,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${transaksi.isIncome ? '+' : '-'}Rp ${_formatRupiah(transaksi.amount)}",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: transaksi.isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if ((transaksi.photoUrl != null &&
                        transaksi.photoUrl!.isNotEmpty) ||
                    (transaksi.photoPath != null &&
                        transaksi.photoPath!.isNotEmpty))
                  GestureDetector(
                    onTap: () => _showFullImage(context, transaksi),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      height: 180,
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: transaksi.photoUrl != null &&
                              transaksi.photoUrl!.isNotEmpty
                          ? Image.network(
                              transaksi.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return transaksi.photoPath != null
                                    ? Image.file(
                                        File(transaksi.photoPath!),
                                        fit: BoxFit.cover,
                                      )
                                    : const SizedBox.shrink();
                              },
                            )
                          : Image.file(
                              File(transaksi.photoPath!),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                _buildDetailRow('Jenis Kategori', transaksi.nameKategori ?? '-',
                    Icons.label),
                const SizedBox(height: 12),
                _buildDetailRow(
                    'Kategori', transaksi.nameCategory ?? '-', Icons.category),
                const SizedBox(height: 12),
                _buildDetailRow('Tanggal', _formatDate(transaksi.date),
                    Icons.calendar_today),
                const SizedBox(height: 12),
                if (transaksi.description != null &&
                    transaksi.description!.isNotEmpty)
                  _buildDetailRow(
                      'Deskripsi', transaksi.description!, Icons.description),
                if (transaksi.description != null &&
                    transaksi.description!.isNotEmpty)
                  const SizedBox(height: 12),
                _buildDetailRow(
                    'Status', 'Selesai', Icons.check_circle, Colors.green),
                const SizedBox(height: 20),
                // Tombol hapus saja, full lebar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Hapus Transaksi'),
                          content: const Text(
                              'Yakin ingin menghapus transaksi ini?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Hapus',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        try {
                          await TransaksiService.delete(transaksi.id!, context);
                          Navigator.pop(context, true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Transaksi berhasil dihapus'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal menghapus transaksi: $e'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Hapus'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon,
      [Color? valueColor]) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.grey.shade600,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: valueColor ?? Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatRupiah(int value) {
    final str = value.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  void _showFullImage(BuildContext context, TransaksiModel t) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (ctx) {
        return GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  child: Center(
                    child: t.photoUrl != null && t.photoUrl!.isNotEmpty
                        ? Image.network(
                            t.photoUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) {
                              return t.photoPath != null
                                  ? Image.file(
                                      File(t.photoPath!),
                                      fit: BoxFit.contain,
                                    )
                                  : const SizedBox.shrink();
                            },
                          )
                        : (t.photoPath != null
                            ? Image.file(
                                File(t.photoPath!),
                                fit: BoxFit.contain,
                              )
                            : const SizedBox.shrink()),
                  ),
                ),
              ),
              Positioned(
                top: 24,
                right: 24,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<bool?> showTransactionDetailBottomSheet(
    BuildContext context, TransaksiModel transaksi) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TransactionDetailBottomSheet(transaksi: transaksi),
  );
}
