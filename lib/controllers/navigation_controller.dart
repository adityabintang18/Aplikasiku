import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../presentation/screens/dashboard/dashboard.dart';
import '../presentation/screens/financial/financial.dart';
import '../presentation/screens/profile/profile_page.dart';
import '../presentation/screens/statistics/statistics_page.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key, int? initialIndex});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController(), permanent: true);
    if (!controller.isInitialized) {
      controller.setInitialIndex(0);
    }

    return Obx(
      () => Scaffold(
        bottomNavigationBar: NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          destinations: const [
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.house),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.wallet),
              label: 'Keuangan',
            ),
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.chartArea),
              label: 'Statistik',
            ),
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.user),
              label: 'Profil',
            ),
          ],
        ),
        body: controller.screens[controller.selectedIndex.value],
      ),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  bool isInitialized = false;

  final screens = [
    Dashboard(),
    Financial(),
    StatisticsPage(),
    ProfilePage(),
  ];

  void setInitialIndex(int index) {
    selectedIndex.value = 0;
    isInitialized = true;
  }
}
