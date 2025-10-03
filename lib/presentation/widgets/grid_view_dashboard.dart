import '../../../models/model.dart';
import 'package:flutter/material.dart';
import '../../../config/size_config.dart';
import 'custom_menu.dart';

class GridViewDashboard extends StatelessWidget {
  const GridViewDashboard({Key? key, required this.menus}) : super(key: key);

  final List<MenuModel> menus;

  @override
  Widget build(BuildContext context) {
    // Perhitungan jumlah baris
    final int rowCount = (menus.length / 3).ceil();
    final double itemHeight = SizeConfig.blockSizeVertical * 14;
    final double mainAxisSpacing = SizeConfig.blockSizeVertical * 2.5;
    // Ubah verticalPadding menjadi lebih kecil agar jarak atas-bawah tidak terlalu jauh
    final double verticalPadding = SizeConfig.blockSizeVertical * 1.2;
    final double totalHeight = (rowCount * itemHeight) +
        ((rowCount - 1) * mainAxisSpacing) +
        (verticalPadding * 2);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 4,
      ),
      child: SizedBox(
        height: totalHeight,
        child: GridView.builder(
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: SizeConfig.blockSizeHorizontal * 4,
            mainAxisSpacing: mainAxisSpacing,
            mainAxisExtent: itemHeight,
          ),
          itemCount: menus.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: CustomMenu(
                menu: menus[index].menu!,
                icon: menus[index].icon!,
              ),
            );
          },
        ),
      ),
    );
  }
}
