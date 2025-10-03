import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/size_config.dart';

class LiturgicalTodayCard extends StatelessWidget {
  const LiturgicalTodayCard({
    Key? key,
    required this.feast,
    required this.readings,
    required this.color,
    this.textColor,
  }) : super(key: key);

  final String feast;
  final Map<String, String> readings;
  final Color color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final String today =
        DateFormat('EEEE, d MMMM y', 'id_ID').format(DateTime.now());

    final Color mainTextColor = textColor ?? Colors.white;
    final Color secondaryTextColor =
        textColor != null ? textColor!.withOpacity(0.7) : Colors.white70;

    // Ambil nama-nama bacaan saja (misal: "Lukas", "Mazmur", "Ibrani", dst)
    final List<String> namaBacaan = readings.keys.toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 4,
        vertical: SizeConfig.blockSizeVertical * 2,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
        // Hapus boxShadow karena sudah dihandle di ListView-nya
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            today,
            style: GoogleFonts.poppins(
              color: secondaryTextColor,
              fontSize: SizeConfig.blockWidth * 3.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: SizeConfig.blockHeight * 0.8),
          Text(
            feast,
            style: GoogleFonts.poppins(
              color: mainTextColor,
              fontSize: SizeConfig.blockWidth * 4.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: SizeConfig.blockHeight * 1.2),
          Text(
            "Bacaan:",
            style: GoogleFonts.poppins(
              color: mainTextColor,
              fontSize: SizeConfig.blockWidth * 3.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: SizeConfig.blockHeight * 0.5),
          Text(
            namaBacaan.isNotEmpty
                ? namaBacaan.map((e) => e.toLowerCase()).join(', ')
                : "-",
            style: GoogleFonts.poppins(
              color: mainTextColor,
              fontSize: SizeConfig.blockWidth * 3.3,
            ),
          ),
        ],
      ),
    );
  }
}
