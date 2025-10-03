import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/size_config.dart';
import '../../../models/model.dart';
import '../../widgets/app_bar_dashboard.dart';
import '../../widgets/list_view_dashboard.dart';
import '../../widgets/grid_view_dashboard.dart';
import '../../../services/calender_liturgical_service.dart';
import '../../../constants/data_constants.dart';
import 'package:aplikasiku/services/auth_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  static const Color _backgroundColor = Color(0xFFF8F9FA);
  static const Color _primaryTextColor = Color(0xFF2C3E50);
  static const Color _accentColor = Color(0xFF6C5CE7);

  late CalenderLiturgicalService apiService;
  List<CalendarDay> _liturgicalData = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthService.checkAndLogoutIfExpired(context);
    });
    apiService = CalenderLiturgicalService(baseUrl: "http://192.168.1.10:8000");
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final today = await apiService.fetchKalenderHariIni(context);
      setState(() {
        if (today != null) {
          _liturgicalData = [today]; // ✅ hanya hari ini
        } else {
          _liturgicalData = [];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: const AppBarDashboard(), // pakai widget, bukan fungsi
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text("Error: $_errorMessage"));
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLiturgicalSection(),
          _buildSpacing(3),
          _buildQuickActionsSection(),
          _buildSpacing(4),
        ],
      ),
    );
  }

  Widget _buildLiturgicalSection() {
    return Container(
      margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Kalender Liturgi Hari Ini'),
          _buildSpacing(2.5),
          ListViewDashboard(data: _liturgicalData),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitleWithAccent('Aksi Cepat'),
          _buildSpacing(1.5),
          GridViewDashboard(
            menus: menuConstant.map((e) => MenuModel.fromJson(e)).toList(),
          ),
        ],
      ),
    );
  }

  // --- helper UI ---
  Widget _buildSectionTitleWithAccent(String title) {
    return Row(
      children: [
        _buildAccentBar(),
        _buildSpacing(3, isHorizontal: true),
        Text(title, style: _buildTitleTextStyle()),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 5,
      ),
      child: Text(title, style: _buildTitleTextStyle()),
    );
  }

  Widget _buildAccentBar() {
    return Container(
      width: 4,
      height: SizeConfig.blockSizeVertical * 2.5,
      decoration: BoxDecoration(
        color: _accentColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  TextStyle _buildTitleTextStyle() {
    return GoogleFonts.poppins(
      color: _primaryTextColor,
      fontSize: SizeConfig.blockSizeHorizontal * 4.8,
      fontWeight: FontWeight.w600,
    );
  }

  Widget _buildSpacing(double size, {bool isHorizontal = false}) {
    if (isHorizontal) {
      return SizedBox(width: SizeConfig.blockSizeHorizontal * size);
    }
    return SizedBox(height: SizeConfig.blockSizeVertical * size);
  }
}
