import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const Loader({
    super.key,
    this.size = 24,
    this.color = Colors.white,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
