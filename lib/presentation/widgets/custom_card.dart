import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/size_config.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    Key? key,
    required this.color,
    required this.total,
    required this.pemasukan,
    required this.pengeluaran,
  }) : super(key: key);

  final Color color;
  final int total;
  final int pemasukan;
  final int pengeluaran;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 5,
        vertical: SizeConfig.blockSizeVertical * 3,
      ),
      width: SizeConfig.blockSizeHorizontal * 85,
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.circular(SizeConfig.blockSizeHorizontal * 3.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul
          Text(
            "Ringkasan Keuangan",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: SizeConfig.blockSizeHorizontal * 5,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),

          // Total
          FittedBox(
            alignment: Alignment.centerLeft,
            child: Text(
              "Rp. $total",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: SizeConfig.blockSizeHorizontal * 7,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),

          // Pemasukan & Pengeluaran
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildItem("Pemasukan", pemasukan, Colors.greenAccent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildItem("Pengeluaran", pengeluaran, Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String label, int value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.8),
            fontSize: SizeConfig.blockSizeHorizontal * 3.8,
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            "Rp. $value",
            style: GoogleFonts.poppins(
              color: valueColor,
              fontSize: SizeConfig.blockSizeHorizontal * 4.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
