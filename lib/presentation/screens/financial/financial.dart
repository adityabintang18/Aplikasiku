import 'package:flutter/material.dart';
import 'package:aplikasiku/config/size_config.dart';
import 'package:aplikasiku/presentation/widgets/tab_menu.dart';
import 'package:aplikasiku/presentation/widgets/app_bar_financial.dart';
import 'package:aplikasiku/presentation/widgets/picker_category_financial.dart';
import 'package:aplikasiku/presentation/widgets/listview_harian.dart';
import 'package:aplikasiku/presentation/widgets/listview_bulanan.dart';
import 'package:aplikasiku/presentation/widgets/listview_kalender.dart';
// import '../../widgets/listview_laporan.dart';
import 'package:aplikasiku/controllers/category_financial_controller.dart';
import 'package:aplikasiku/presentation/widgets/picker_month_year.dart';
import 'package:aplikasiku/services/auth_service.dart';

class Financial extends StatefulWidget {
  const Financial({super.key});

  @override
  State<Financial> createState() => _FinancialState();
}

class _FinancialState extends State<Financial>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  final ValueNotifier<DateTime> _selectedDateNotifier =
      ValueNotifier<DateTime>(DateTime.now());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthService.checkAndLogoutIfExpired(context);
    });
    _tabController = TabController(length: 3, vsync: this);
    _selectedDateNotifier.value = _selectedDate;
    _selectedDateNotifier.addListener(_onSelectedDateChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _selectedDateNotifier.removeListener(_onSelectedDateChanged);
    _selectedDateNotifier.dispose();
    super.dispose();
  }

  void _onSelectedDateChanged() {
    if (CategoryFinancialController.selectedDate != null) {
      CategoryFinancialController.selectedDate.value =
          _selectedDateNotifier.value;
    }
  }

  void _onMonthChanged(String monthName) {
    final months = [
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
    int monthIndex = months.indexOf(monthName) + 1;
    if (monthIndex > 0) {
      _selectedDate = DateTime(_selectedDate.year, monthIndex);
      _selectedDateNotifier.value = _selectedDate;
    }
  }

  void _onYearChanged(int year) {
    _selectedDate = DateTime(year, _selectedDate.month);
    _selectedDateNotifier.value = _selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
                const AppBarFinancial(),
                // Picker Categorial
                ValueListenableBuilder<bool>(
                  valueListenable: CategoryFinancialController.isExpanded,
                  builder: (context, expanded, _) {
                    if (!expanded) return const SliverToBoxAdapter();
                    return SliverPersistentHeader(
                      pinned: true,
                      delegate: _FixedHeaderDelegate(
                        height: SizeConfig.blockSizeVertical * 15,
                        selectedDate: _selectedDate,
                        child: Material(
                          color: Colors.transparent,
                          child: const PickerCategoryFinancial(),
                        ),
                      ),
                    );
                  },
                ),
                // Picker Month Year
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _FixedHeaderDelegate(
                    height: SizeConfig.blockSizeVertical * 6,
                    selectedDate: _selectedDate,
                    child: Material(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: Center(
                          child: SizedBox(
                            width: 320,
                            child: PickerMonthYear(
                              selectedMonth: _monthName(_selectedDate.month),
                              selectedYear: _selectedDate.year,
                              onMonthChanged: _onMonthChanged,
                              onYearChanged: _onYearChanged,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Tab
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _FixedHeaderDelegate(
                    height: SizeConfig.blockSizeVertical *
                        6, // Pakai SizeConfig untuk tinggi TabMenu
                    selectedDate: _selectedDate,
                    child: Material(
                      color: Colors.white,
                      child: Align(
                        alignment: Alignment.center, // biar gak ada jarak
                        child: TabMenu(tabController: _tabController),
                      ),
                    ),
                  ),
                ),
              ],
          body: ValueListenableBuilder<DateTime>(
            valueListenable: _selectedDateNotifier,
            builder: (context, selectedDate, _) {
              return TabBarView(
                controller: _tabController,
                children: [
                  ListViewHarian(selectedDate: selectedDate),
                  ListViewBulanan(selectedDate: selectedDate),
                  ListViewKalender(selectedDate: selectedDate),
                  // ListViewLaporan(selectedDate: selectedDate),
                ],
              );
            },
          )),
    );
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
}

class _FixedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  final DateTime selectedDate;

  _FixedHeaderDelegate({
    required this.child,
    required this.height,
    required this.selectedDate,
  });

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: height,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _FixedHeaderDelegate oldDelegate) {
    return oldDelegate.selectedDate != selectedDate;
  }
}
