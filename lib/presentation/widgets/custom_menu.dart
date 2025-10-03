import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/size_config.dart';
import '../screens/profile/profile_page.dart';

// Import fungsi global showAddTransactionBottomSheet dari listview_harian.dart
import '../widgets/add_transaction_bottomsheet.dart'
    show showAddTransactionBottomSheet;

// Import halaman Catatan
import '../screens/notes/notes_page.dart';

class CustomMenu extends StatefulWidget {
  const CustomMenu({Key? key, required this.menu, required this.icon})
      : super(key: key);

  final String menu;
  final IconData icon;

  @override
  State<CustomMenu> createState() => _CustomMenuState();
}

class _CustomMenuState extends State<CustomMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToPage(BuildContext context) {
    switch (widget.menu) {
      case 'Keuangan':
        // Tampilkan bottom sheet tambah transaksi menggunakan fungsi global
        showAddTransactionBottomSheet(context, DateTime.now());
        break;
      case 'Profil':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
      case 'Catatan':
        // Navigasi ke halaman Catatan
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotesPage()),
        );
        break;
      default:
        // Tampilkan dialog "segera hadir" untuk menu lain
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Segera Hadir',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Fitur ${widget.menu} sedang dalam pengembangan.',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6C5CE7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: () => _navigateToPage(context),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: SizeConfig.blockSizeHorizontal * 14,
                      height: SizeConfig.blockSizeHorizontal * 14,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF6C5CE7),
                            Color(0xFFA29BFE),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: FaIcon(
                          widget.icon,
                          size: SizeConfig.blockSizeHorizontal * 6.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: SizeConfig.blockSizeVertical * 1),
                    Flexible(
                      child: Text(
                        widget.menu,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2C3E50),
                          fontSize: SizeConfig.blockSizeHorizontal * 3,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Contoh penggunaan di ListView
class CustomMenuListView extends StatelessWidget {
  final List<Map<String, dynamic>> menuList = [
    {
      'menu': 'Keuangan',
      'icon': FontAwesomeIcons.wallet,
    },
    {
      'menu': 'Catatan',
      'icon': FontAwesomeIcons.noteSticky,
    },
    {
      'menu': 'Profil',
      'icon': FontAwesomeIcons.user,
    },
    {
      'menu': 'Statistik',
      'icon': FontAwesomeIcons.chartPie,
    },
    {
      'menu': 'Pengaturan',
      'icon': FontAwesomeIcons.gear,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: menuList.length,
      separatorBuilder: (context, index) => SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = menuList[index];
        return CustomMenu(
          menu: item['menu'],
          icon: item['icon'],
        );
      },
    );
  }
}
