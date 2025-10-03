import 'package:get/get.dart';
import 'package:aplikasiku/presentation/screens/splash_screen/splash_screen.dart';
import 'package:aplikasiku/presentation/screens/auth/sign_in_screen.dart';
import 'package:aplikasiku/presentation/screens/dashboard/dashboard.dart';
import 'package:aplikasiku/presentation/screens/statistics/statistics_page.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const statistics = '/statistics';

  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: login,
      page: () => const SignInScreen(),
    ),
    GetPage(
      name: home,
      page: () => const Dashboard(),
    ),
    GetPage(
      name: statistics,
      page: () => const StatisticsPage(),
    ),
  ];
}
