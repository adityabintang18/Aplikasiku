import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  const ToggleButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) {
            return isSelected ? Colors.deepPurpleAccent : Colors.transparent;
          } else if (states.contains(WidgetState.hovered)) {
            return isSelected
                ? Colors.deepPurpleAccent
                : Colors.white.withOpacity(0.1);
          }
          return isSelected ? Colors.deepPurpleAccent : Colors.transparent;
        }),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        minimumSize: WidgetStateProperty.all(const Size(double.infinity, 50)),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.white : Colors.deepPurpleAccent,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
