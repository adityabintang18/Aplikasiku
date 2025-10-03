import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/size_config.dart';
import '../../controllers/category_financial_controller.dart';

class AppBarFinancial extends StatelessWidget {
  const AppBarFinancial({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6C5CE7),
              Color(0xFFA29BFE),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 4,
              vertical: SizeConfig.blockSizeVertical * 1,
            ),
            child: Center(
              child: ValueListenableBuilder<String>(
                valueListenable:
                    CategoryFinancialController.selectedCategoryName,
                builder: (context, categoryName, _) {
                  return GestureDetector(
                    onTap: () {
                      CategoryFinancialController.isExpanded.value =
                          !CategoryFinancialController.isExpanded.value;
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ValueListenableBuilder<bool>(
                          valueListenable:
                              CategoryFinancialController.isExpanded,
                          builder: (context, expanded, _) {
                            return AnimatedRotation(
                              turns: expanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              child: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 22,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (categoryName.isEmpty) ? "Semua" : categoryName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: SizeConfig.blockSizeHorizontal * 4.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
