import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';

class Constant {
  static const buttonClr = Color(0xFF6C5CE7);
}

class PickerMonthYear extends StatefulWidget {
  final String selectedMonth;
  final int selectedYear;
  final ValueChanged<String> onMonthChanged;
  final ValueChanged<int> onYearChanged;

  const PickerMonthYear({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onMonthChanged,
    required this.onYearChanged,
  });

  @override
  State<PickerMonthYear> createState() => _PickerMonthYearState();
}

class _PickerMonthYearState extends State<PickerMonthYear> {
  late int month;
  late int year;
  late List<String> months;

  @override
  void initState() {
    super.initState();
    months = List.generate(
      12,
      (index) => DateFormat('MMMM', 'id_ID').format(DateTime(0, index + 1)),
    );
    month = months.indexOf(widget.selectedMonth) + 1;
    year = widget.selectedYear;
  }

  @override
  void didUpdateWidget(covariant PickerMonthYear oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newMonth = months.indexOf(widget.selectedMonth) + 1;
    final newYear = widget.selectedYear;
    if (newMonth != month || newYear != year) {
      setState(() {
        month = newMonth;
        year = newYear;
      });
    }
  }

  void _changeMonth(int delta) {
    int newMonth = month + delta;
    int newYear = year;

    if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    } else if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    }

    setState(() {
      month = newMonth;
      year = newYear;
    });
    widget.onMonthChanged(months[month - 1]);
    widget.onYearChanged(year);
  }

  Future<void> _showMonthYearPicker() async {
    final picked = await showMonthPicker(
      context: context,
      initialDate: DateTime(year, month),
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
      locale: const Locale("id"),
    );

    if (picked != null) {
      setState(() {
        month = picked.month;
        year = picked.year;
      });
      widget.onMonthChanged(months[month - 1]);
      widget.onYearChanged(year);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => _changeMonth(-1),
          icon: const Icon(Icons.chevron_left),
          color: Constant.buttonClr,
          splashRadius: 20,
        ),
        GestureDetector(
          onTap: _showMonthYearPicker,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: child,
            ),
            child: Text(
              "${months[month - 1]} $year",
              key: ValueKey("$month-$year"),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Constant.buttonClr,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => _changeMonth(1),
          icon: const Icon(Icons.chevron_right),
          color: Constant.buttonClr,
          splashRadius: 20,
        ),
      ],
    );
  }
}
