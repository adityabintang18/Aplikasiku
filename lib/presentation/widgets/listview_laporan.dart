import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ListViewLaporan extends StatelessWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>>? reportData;

  const ListViewLaporan({
    Key? key,
    required this.selectedDate,
    this.reportData,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final data = reportData ?? _generateDummyReportData();

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan icon dan title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: item['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Icon(
                        item['icon'],
                        color: item['color'],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['subtitle'],
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: item['statusColor'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        item['status'],
                        style: GoogleFonts.poppins(
                          color: item['statusColor'],
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Chart atau visual representation
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Grafik ${item['title']}',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Key metrics
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Total',
                        item['totalAmount'],
                        item['color'],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Rata-rata',
                        item['averageAmount'],
                        item['color'],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Tren',
                        item['trend'],
                        item['trendColor'],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Export report
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Export ${item['title']}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Export'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: item['color'],
                          side: BorderSide(color: item['color']),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: View details
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lihat detail ${item['title']}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('Detail'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: item['color'],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateDummyReportData() {
    return [
      {
        'title': 'Laporan Pengeluaran',
        'subtitle':
            'Ringkasan pengeluaran ${_monthName(selectedDate.month)} ${selectedDate.year}',
        'icon': Icons.trending_down,
        'color': Colors.red,
        'status': 'Selesai',
        'statusColor': Colors.green,
        'totalAmount': 'Rp 7.200.000',
        'averageAmount': 'Rp 240.000',
        'trend': '+12%',
        'trendColor': Colors.red,
      },
      {
        'title': 'Laporan Pemasukan',
        'subtitle':
            'Ringkasan pemasukan ${_monthName(selectedDate.month)} ${selectedDate.year}',
        'icon': Icons.trending_up,
        'color': Colors.green,
        'status': 'Selesai',
        'statusColor': Colors.green,
        'totalAmount': 'Rp 8.500.000',
        'averageAmount': 'Rp 283.333',
        'trend': '+8%',
        'trendColor': Colors.green,
      },
      {
        'title': 'Laporan Kategori',
        'subtitle': 'Analisis pengeluaran berdasarkan kategori',
        'icon': Icons.pie_chart,
        'color': Colors.blue,
        'status': 'Dalam Proses',
        'statusColor': Colors.orange,
        'totalAmount': '6 Kategori',
        'averageAmount': 'Rp 1.200.000',
        'trend': 'Stabil',
        'trendColor': Colors.grey,
      },
      {
        'title': 'Laporan Tren',
        'subtitle': 'Analisis tren keuangan 3 bulan terakhir',
        'icon': Icons.show_chart,
        'color': Colors.purple,
        'status': 'Selesai',
        'statusColor': Colors.green,
        'totalAmount': '3 Bulan',
        'averageAmount': 'Rp 7.800.000',
        'trend': '+5%',
        'trendColor': Colors.green,
      },
    ];
  }
}
