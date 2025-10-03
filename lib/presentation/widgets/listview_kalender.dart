import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasiku/services/transaksi_service.dart';
import 'package:aplikasiku/controllers/category_financial_controller.dart';

class ListViewKalender extends StatefulWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>>? calendarData;

  const ListViewKalender({
    Key? key,
    required this.selectedDate,
    this.calendarData,
  }) : super(key: key);

  @override
  State<ListViewKalender> createState() => _ListViewKalenderState();
}

class _ListViewKalenderState extends State<ListViewKalender> {
  late DateTime _selectedDay;
  List<Map<String, dynamic>> _cachedCalendarData = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDate;
    CategoryFinancialController.selectedCategoryId
        .addListener(_onFilterChanged);
    _loadCalendar();
  }

  @override
  void didUpdateWidget(covariant ListViewKalender oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _selectedDay = widget.selectedDate;
      _loadCalendar();
    }
  }

  void _selectDay(int day) {
    setState(() {
      _selectedDay =
          DateTime(widget.selectedDate.year, widget.selectedDate.month, day);
    });
    _showDayDetail(day);
  }

  void _showDayDetail(int day) {
    final dayData = _getDayData(day);
    final dayTransactions = _getDayTransactions(day);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: _DayDetailBottomSheet(
            day: day,
            dayData: dayData,
            transactions: dayTransactions,
            selectedDate: widget.selectedDate,
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getDayData(int day) {
    final calendarData = widget.calendarData ?? _cachedCalendarData;
    return calendarData.firstWhere(
      (data) => data['day'] == day,
      orElse: () => {'income': 0, 'expense': 0, 'hasTransaction': false},
    );
  }

  List<Map<String, dynamic>> _getDayTransactions(int day) {
    final dayData = _getDayData(day);
    if (!dayData['hasTransaction']) return [];
    final tx = (dayData['transactions'] as List?) ?? [];
    return tx.cast<Map<String, dynamic>>();
  }

  String _formatRupiah(int value) {
    final str = value.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  Widget _buildSummaryCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendarData = widget.calendarData ?? _cachedCalendarData;
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final daysInMonth =
        DateTime(widget.selectedDate.year, widget.selectedDate.month + 1, 0)
            .day;
    final firstDayOfMonth =
        DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    // Calculate monthly totals
    int totalIncome = 0;
    int totalExpense = 0;
    for (var data in calendarData) {
      totalIncome += (data['income'] ?? 0) as int;
      totalExpense += (data['expense'] ?? 0) as int;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Monthly Summary
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurpleAccent,
                  Colors.deepPurpleAccent.shade700
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurpleAccent.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ringkasan Bulanan',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Pemasukan',
                        '+Rp ${_formatRupiah(totalIncome)}',
                        Colors.green,
                        Icons.arrow_upward,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Pengeluaran',
                        '-Rp ${_formatRupiah(totalExpense)}',
                        Colors.red,
                        Icons.arrow_downward,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Colors.deepPurpleAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Saldo: Rp ${_formatRupiah(totalIncome - totalExpense)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: totalIncome - totalExpense >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Calendar Grid
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Day headers
                Row(
                  children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                      .map((day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),

                // Calendar days
                ...List.generate(6, (weekIndex) {
                  return Row(
                    children: List.generate(7, (dayIndex) {
                      final dayNumber =
                          (weekIndex * 7) + dayIndex - firstWeekday + 2;

                      if (dayNumber < 1 || dayNumber > daysInMonth) {
                        return Expanded(child: Container(height: 40));
                      }

                      final isSelected = _selectedDay.day == dayNumber &&
                          _selectedDay.month == widget.selectedDate.month &&
                          _selectedDay.year == widget.selectedDate.year;

                      final dayData = calendarData.firstWhere(
                        (data) => data['day'] == dayNumber,
                        orElse: () => {
                          'income': 0,
                          'expense': 0,
                          'hasTransaction': false
                        },
                      );

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDay(dayNumber),
                          child: Container(
                            height: 40,
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.deepPurpleAccent
                                  : dayData['hasTransaction']
                                      ? Colors.deepPurpleAccent.withOpacity(0.1)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(
                                      color: Colors.deepPurpleAccent, width: 2)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayNumber.toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                // Visual indicators for income and expense
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Income indicator (green light)
                                    Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 1),
                                      decoration: BoxDecoration(
                                        color: dayData['income'] > 0
                                            ? (isSelected
                                                ? Colors.white
                                                : Colors.green)
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                        boxShadow: dayData['income'] > 0
                                            ? [
                                                BoxShadow(
                                                  color: Colors.green
                                                      .withOpacity(0.6),
                                                  blurRadius: 3,
                                                  spreadRadius: 1,
                                                )
                                              ]
                                            : null,
                                      ),
                                    ),
                                    // Expense indicator (red light)
                                    Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 1),
                                      decoration: BoxDecoration(
                                        color: dayData['expense'] > 0
                                            ? (isSelected
                                                ? Colors.white
                                                : Colors.red)
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                        boxShadow: dayData['expense'] > 0
                                            ? [
                                                BoxShadow(
                                                  color: Colors.red
                                                      .withOpacity(0.6),
                                                  blurRadius: 3,
                                                  spreadRadius: 1,
                                                )
                                              ]
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Analysis Section
          _buildAnalysisSection(calendarData),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(List<Map<String, dynamic>> calendarData) {
    final analysis = _generateAnalysis(calendarData);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analisis Bulanan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurpleAccent,
            ),
          ),
          const SizedBox(height: 16),

          // Top spending day
          _buildAnalysisCard(
            'Tanggal Pengeluaran Terbanyak',
            '${analysis['topSpendingDay']}',
            'Rp ${_formatRupiah(analysis['topSpendingAmount'])}',
            Colors.red,
            Icons.trending_down,
          ),

          const SizedBox(height: 12),

          // Top income day
          _buildAnalysisCard(
            'Tanggal Pemasukan Terbanyak',
            '${analysis['topIncomeDay']}',
            'Rp ${_formatRupiah(analysis['topIncomeAmount'])}',
            Colors.green,
            Icons.trending_up,
          ),

          const SizedBox(height: 12),

          // Most active day
          _buildAnalysisCard(
            'Tanggal Paling Aktif',
            '${analysis['mostActiveDay']}',
            '${analysis['mostActiveCount']} transaksi',
            Colors.blue,
            Icons.event,
          ),

          const SizedBox(height: 12),

          // Average daily spending
          _buildAnalysisCard(
            'Rata-rata Pengeluaran Harian',
            'Per hari',
            'Rp ${_formatRupiah(analysis['avgDailySpending'])}',
            Colors.orange,
            Icons.calculate,
          ),

          const SizedBox(height: 12),

          // Total transaction days
          _buildAnalysisCard(
            'Hari dengan Transaksi',
            '${analysis['transactionDays']} dari ${analysis['totalDays']} hari',
            '${analysis['activityPercentage']}% aktif',
            Colors.purple,
            Icons.pie_chart,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(
      String title, String subtitle, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _generateAnalysis(
      List<Map<String, dynamic>> calendarData) {
    int topSpendingAmount = 0;
    int topSpendingDay = 0;
    int topIncomeAmount = 0;
    int topIncomeDay = 0;
    int mostActiveCount = 0;
    int mostActiveDay = 0;
    int totalSpending = 0;
    int transactionDays = 0;

    for (var data in calendarData) {
      final day = data['day'] as int;
      final income = data['income'] as int;
      final expense = data['expense'] as int;
      final hasTransaction = data['hasTransaction'] as bool;

      // Track top spending day
      if (expense > topSpendingAmount) {
        topSpendingAmount = expense;
        topSpendingDay = day;
      }

      // Track top income day
      if (income > topIncomeAmount) {
        topIncomeAmount = income;
        topIncomeDay = day;
      }

      // Track most active day (most transactions)
      final transactionCount = (data['transactions'] is List)
          ? (data['transactions'] as List).length
          : ((day % 4) + 1); // fallback if not available
      if (hasTransaction && transactionCount > mostActiveCount) {
        mostActiveCount = transactionCount;
        mostActiveDay = day;
      }

      // Calculate totals
      totalSpending += expense;
      if (hasTransaction) transactionDays++;
    }

    final totalDays = calendarData.length;
    final avgDailySpending =
        transactionDays > 0 ? totalSpending ~/ transactionDays : 0;
    final activityPercentage =
        totalDays > 0 ? ((transactionDays / totalDays) * 100).round() : 0;

    return {
      'topSpendingDay': topSpendingDay,
      'topSpendingAmount': topSpendingAmount,
      'topIncomeDay': topIncomeDay,
      'topIncomeAmount': topIncomeAmount,
      'mostActiveDay': mostActiveDay,
      'mostActiveCount': mostActiveCount,
      'avgDailySpending': avgDailySpending,
      'transactionDays': transactionDays,
      'totalDays': totalDays,
      'activityPercentage': activityPercentage,
    };
  }

  void _onFilterChanged() {
    _loadCalendar();
  }

  @override
  void dispose() {
    CategoryFinancialController.selectedCategoryId
        .removeListener(_onFilterChanged);
    super.dispose();
  }

  Future<void> _loadCalendar() async {
    setState(() => _loading = true);
    try {
      if (widget.calendarData != null) {
        _cachedCalendarData = widget.calendarData!;
      } else {
        final jenisId = CategoryFinancialController.selectedCategoryId.value;
        _cachedCalendarData = await TransaksiService.getCalendar(
          widget.selectedDate,
          context,
          jenisKategori: jenisId,
        );
      }
    } catch (_) {
      _cachedCalendarData = [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _DayDetailBottomSheet extends StatelessWidget {
  final int day;
  final Map<String, dynamic> dayData;
  final List<Map<String, dynamic>> transactions;
  final DateTime selectedDate;

  const _DayDetailBottomSheet({
    Key? key,
    required this.day,
    required this.dayData,
    required this.transactions,
    required this.selectedDate,
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

  String _formatRupiah(int value) {
    final str = value.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime(selectedDate.year, selectedDate.month, day);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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

            const SizedBox(height: 16),

            // Date info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.deepPurpleAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatDate(date),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Summary cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Pemasukan',
                    '+Rp ${_formatRupiah(dayData['income'] ?? 0)}',
                    Colors.green,
                    Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Pengeluaran',
                    '-Rp ${_formatRupiah(dayData['expense'] ?? 0)}',
                    Colors.red,
                    Icons.arrow_downward,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Transactions list
            if (transactions.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_note,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada transaksi',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'pada hari ini',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daftar Transaksi',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...transactions
                      .map((transaction) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: CircleAvatar(
                                backgroundColor: transaction['isIncome'] == true
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                child: Icon(
                                  transaction['isIncome'] == true
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: transaction['isIncome'] == true
                                      ? Colors.green
                                      : Colors.red,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                (transaction['title'] ?? '').toString(),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                (transaction['nameCategory'] ?? '-').toString(),
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Text(
                                (transaction['isIncome'] == true ? '+' : '-') +
                                    'Rp ' +
                                    _formatRupiah(int.tryParse(
                                            (transaction['amount'] ?? '0')
                                                .toString()
                                                .replaceAll('+', '')
                                                .replaceAll('-', '')) ??
                                        0),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: transaction['isIncome'] == true
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
