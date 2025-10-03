import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../models/model.dart';

class GridViewTransaction extends StatefulWidget {
  const GridViewTransaction({Key? key, required this.transactions})
      : super(key: key);

  final List<TransactionModel> transactions;

  @override
  State<GridViewTransaction> createState() => _GridViewTransactionState();
}

class _GridViewTransactionState extends State<GridViewTransaction> {
  final Map<String, bool> expandedStatus = {};

  @override
  Widget build(BuildContext context) {
    final Map<String, List<TransactionModel>> grouped = {};

    for (var trx in widget.transactions) {
      final dateKey = DateTime(trx.date.year, trx.date.month, trx.date.day);
      final keyStr = DateFormat("yyyy-MM-dd").format(dateKey);

      grouped.putIfAbsent(keyStr, () => []);
      grouped[keyStr]!.add(trx);
    }

    // urutkan tanggal terbaru dulu
    final sortedDates = grouped.keys.toList()
      ..sort((a, b) => DateFormat("yyyy-MM-dd")
          .parse(b)
          .compareTo(DateFormat("yyyy-MM-dd").parse(a)));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateStr = sortedDates[index];
        final date = DateFormat("yyyy-MM-dd").parse(dateStr);
        final dayTransactions = grouped[dateStr]!;

        final income = dayTransactions
            .where((trx) => !trx.isExpense)
            .fold<int>(0, (sum, trx) => sum + trx.amount);

        final expense = dayTransactions
            .where((trx) => trx.isExpense)
            .fold<int>(0, (sum, trx) => sum + trx.amount);

        expandedStatus.putIfAbsent(dateStr, () => true);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  expandedStatus[dateStr] = !(expandedStatus[dateStr] ?? true);
                });
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    AnimatedRotation(
                      turns: (expandedStatus[dateStr]! ? 0.5 : 0),
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            // tampilkan tanggal dalam format Indonesia
                            DateFormat("dd MMMM yyyy", "id_ID").format(date),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Pemasukan: +$income",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                "Pengeluaran: -$expense",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (expandedStatus[dateStr]!)
              ...dayTransactions.map(
                (trx) => ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor:
                        trx.isExpense ? Colors.red[50] : Colors.green[50],
                    child: Icon(
                      trx.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                      color: trx.isExpense ? Colors.red : Colors.green,
                    ),
                  ),
                  title: Text(
                    trx.title,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  trailing: Text(
                    trx.isExpense ? "- ${trx.amount}" : "+ ${trx.amount}",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: trx.isExpense ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ),
            const Divider(height: 1),
          ],
        );
      },
    );
  }
}
