import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RingkasanItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const RingkasanItem({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          label == "Pemasukan" ? Icons.arrow_upward : Icons.arrow_downward,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
