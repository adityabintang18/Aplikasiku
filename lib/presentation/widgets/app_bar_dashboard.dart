import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/size_config.dart';
import '../../services/user_service.dart';

class AppBarDashboard extends StatefulWidget implements PreferredSizeWidget {
  const AppBarDashboard({super.key});

  @override
  State<AppBarDashboard> createState() => _AppBarDashboardState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarDashboardState extends State<AppBarDashboard> {
  String userName = "User";

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _refreshFromApi();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? "User";
    });
  }

  Future<void> _refreshFromApi() async {
    final profile = await UserService.getProfile();
    if (profile != null && profile['name'] != null) {
      setState(() {
        userName = profile['name'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Text(
        'Hi, $userName!',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: SizeConfig.blockSizeHorizontal * 4.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
