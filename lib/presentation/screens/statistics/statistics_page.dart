import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:aplikasiku/config/size_config.dart';
import 'package:aplikasiku/services/statistic_service.dart';
import 'package:intl/intl.dart';
import 'package:aplikasiku/services/auth_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 🔐 cek dulu token expired
      await AuthService.checkAndLogoutIfExpired(
        context,
        onLoggedOut: () {
          debugPrint("🔴 Token expired di StatisticPage, logout otomatis");
        },
      );

      // kalau token masih valid → fetch data
      final expired = await AuthService.isTokenExpired();
      if (!expired && mounted) {
        _fetchStatistics();
      }
    });
  }

  Future<void> _fetchStatistics() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await StatisticsService().getStatistics();
      setState(() {
        _data = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan: $e';
        _loading = false;
      });
    }
  }

  String _formatCurrency(num? value) {
    if (value == null) return 'Rp 0';
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6C5CE7),
                Color(0xFFA29BFE),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Statistik',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: SizeConfig.blockSizeHorizontal * 4.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)))
              : _data == null
                  ? const Center(child: Text('Tidak ada data'))
                  : RefreshIndicator(
                      onRefresh: _fetchStatistics,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildOverviewSection(_data!['overview']),
                            SizedBox(height: SizeConfig.blockSizeVertical * 3),
                            _buildChartsSection(_data!['monthly_expenses']),
                            SizedBox(height: SizeConfig.blockSizeVertical * 3),
                            _buildRecentActivitySection(
                                _data!['recent_activities']),
                            SizedBox(height: SizeConfig.blockSizeVertical * 3),
                            _buildCategoriesSection(_data!['categories']),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildOverviewSection(Map<String, dynamic>? overview) {
    if (overview == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan',
          style: GoogleFonts.poppins(
            color: const Color(0xFF2C3E50),
            fontSize: SizeConfig.blockSizeHorizontal * 4.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 2),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Pemasukan',
                _formatCurrency(overview['total_income'] as num?),
                FontAwesomeIcons.arrowUp,
                const Color(0xFF4CAF50),
              ),
            ),
            SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
            Expanded(
              child: _buildStatCard(
                'Total Pengeluaran',
                _formatCurrency(overview['total_expense'] as num?),
                FontAwesomeIcons.arrowDown,
                const Color(0xFFF44336),
              ),
            ),
          ],
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 2),
        _buildStatCard(
          'Saldo Bersih',
          _formatCurrency(overview['net_balance'] as num?),
          FontAwesomeIcons.wallet,
          const Color(0xFF6C5CE7),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2.5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FaIcon(
                  icon,
                  color: color,
                  size: SizeConfig.blockSizeHorizontal * 5,
                ),
              ),
              const Spacer(),
              FaIcon(
                FontAwesomeIcons.chevronRight,
                color: Colors.grey[400],
                size: SizeConfig.blockSizeHorizontal * 3.5,
              ),
            ],
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: SizeConfig.blockSizeHorizontal * 3.2,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: const Color(0xFF2C3E50),
              fontSize: SizeConfig.blockSizeHorizontal * 4.2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(List<dynamic>? monthlyExpenses) {
    if (monthlyExpenses == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grafik Pengeluaran',
          style: GoogleFonts.poppins(
            color: const Color(0xFF2C3E50),
            fontSize: SizeConfig.blockSizeHorizontal * 4.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 2),
        Container(
          height: SizeConfig.blockSizeVertical * 25,
          padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double maxAmount = 0.0;
                    for (var item in monthlyExpenses) {
                      if (item is Map<String, dynamic>) {
                        double amt =
                            (item['amount'] as num?)?.toDouble() ?? 0.0;
                        if (amt > maxAmount) maxAmount = amt;
                      }
                    }
                    if (maxAmount == 0) maxAmount = 1.0;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: monthlyExpenses.map((item) {
                        double amount = 0.0;
                        String label = '';
                        String amountLabel = '';
                        if (item is Map<String, dynamic>) {
                          amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
                          // label = item['month']?.toString() ?? '';
                          // Tampilkan bulan dan tahun, misal: "Sep 2025"
                          String month = item['month']?.toString() ?? '';
                          String year = item['year']?.toString() ?? '';
                          label = "$month $year";
                          amountLabel = _formatCurrency(item['amount'] as num?);
                        }
                        double normalizedHeight = (amount / maxAmount) * 0.8;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildBar(normalizedHeight, label,
                                const Color(0xFF6C5CE7)),
                            SizedBox(
                                height: SizeConfig.blockSizeVertical * 0.5),
                            Text(
                              amountLabel,
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: SizeConfig.blockSizeHorizontal * 2.8,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 2),
              Text(
                'Pengeluaran Bulanan',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: SizeConfig.blockSizeHorizontal * 3.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBar(double height, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: SizeConfig.blockSizeHorizontal * 8,
          height: SizeConfig.blockSizeVertical * 15 * height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 1),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: SizeConfig.blockSizeHorizontal * 3,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(List<dynamic>? activities) {
    if (activities == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aktivitas Terbaru',
          style: GoogleFonts.poppins(
            color: const Color(0xFF2C3E50),
            fontSize: SizeConfig.blockSizeHorizontal * 4.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 2),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < activities.length; i++) ...[
                _buildActivityItem(
                  // Title dari response kosong, fallback ke tipe transaksi
                  _getActivityTitle(activities[i]),
                  _formatCurrency(activities[i]['amount'] as num?),
                  activities[i]['time'] ?? '',
                  _getActivityIcon(activities[i]['icon']),
                  _getActivityColor(activities[i]['color']),
                ),
                if (i != activities.length - 1) _buildDivider(),
              ]
            ],
          ),
        ),
      ],
    );
  }

  String _getActivityTitle(Map<String, dynamic> activity) {
    // Jika title kosong, tampilkan "Pemasukan" atau "Pengeluaran" berdasarkan icon
    String? title = activity['title'];
    if (title != null && title.isNotEmpty) return title;
    String? icon = activity['icon'];
    if (icon == 'arrow_upward') {
      return 'Pemasukan';
    } else if (icon == 'arrow_downward') {
      return 'Pengeluaran';
    }
    return '-';
  }

  IconData _getActivityIcon(String? iconName) {
    // Mapping nama icon dari API ke FontAwesomeIcons
    switch (iconName) {
      case 'arrow_upward':
        return FontAwesomeIcons.arrowUp;
      case 'arrow_downward':
        return FontAwesomeIcons.arrowDown;
      default:
        return FontAwesomeIcons.receipt;
    }
  }

  Color _getActivityColor(String? colorHex) {
    // colorHex: '#F44336' atau null
    if (colorHex == null) return Colors.grey;
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xff')));
    } catch (_) {
      return Colors.grey;
    }
  }

  Widget _buildActivityItem(
      String title, String amount, String time, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2.5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(
              icon,
              color: color,
              size: SizeConfig.blockSizeHorizontal * 4.5,
            ),
          ),
          SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF2C3E50),
                    fontSize: SizeConfig.blockSizeHorizontal * 3.8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: SizeConfig.blockSizeHorizontal * 3,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: SizeConfig.blockSizeHorizontal * 3.8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 4),
      height: 1,
      color: Colors.grey[200],
    );
  }

  Widget _buildCategoriesSection(List<dynamic>? categories) {
    if (categories == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori Pengeluaran',
          style: GoogleFonts.poppins(
            color: const Color(0xFF2C3E50),
            fontSize: SizeConfig.blockSizeHorizontal * 4.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 2),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < categories.length; i++) ...[
                _buildCategoryItem(
                  // category di response adalah int, tampilkan sebagai string
                  categories[i]['category']?.toString() ?? '-',
                  categories[i]['percentage'] ?? '0%',
                  _formatCurrency(categories[i]['amount'] as num?),
                  _getActivityColor(categories[i]['color']),
                ),
                if (i != categories.length - 1) _buildDivider(),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
      String category, String percentage, String amount, Color color) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
      child: Row(
        children: [
          Container(
            width: SizeConfig.blockSizeHorizontal * 4,
            height: SizeConfig.blockSizeHorizontal * 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
          Expanded(
            child: Text(
              category,
              style: GoogleFonts.poppins(
                color: const Color(0xFF2C3E50),
                fontSize: SizeConfig.blockSizeHorizontal * 3.8,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            percentage,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: SizeConfig.blockSizeHorizontal * 3.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
          Text(
            amount,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: SizeConfig.blockSizeHorizontal * 3.5,
            ),
          ),
        ],
      ),
    );
  }
}
