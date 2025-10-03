import 'package:flutter/material.dart';

class TabMenu extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  const TabMenu({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      labelColor: Colors.deepPurpleAccent,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.deepPurpleAccent,
      tabs: const [
        Tab(text: "Harian"),
        Tab(text: "Bulanan"),
        Tab(text: "Kalender"),
        // Tab(text: "Laporan"),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
