import 'package:flutter/material.dart';
import '../../config/size_config.dart';
import 'package:google_fonts/google_fonts.dart';

class TextMenu extends StatelessWidget {
  const TextMenu({Key? key, required this.textMenu}) : super(key: key);
  final String textMenu;
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(
          top: SizeConfig.blockSizeVertical * 1,
          left: SizeConfig.blockSizeHorizontal * 5,
          right: SizeConfig.blockSizeHorizontal * 5,
        ),
        child: Text(textMenu,
            textAlign: TextAlign.start,
            style: GoogleFonts.poppins(
                color: const Color(0XFF111111),
                fontSize: SizeConfig.blockSizeHorizontal * 4.5,
                fontWeight: FontWeight.w500)));
  }
}
