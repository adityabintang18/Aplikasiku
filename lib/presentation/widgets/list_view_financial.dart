import 'package:flutter/material.dart';
import '../../models/model.dart';
import 'custom_card.dart';
import '../../config/size_config.dart';

class ListViewFinancial extends StatelessWidget {
  const ListViewFinancial({
    Key? key,
    required this.data,
  }) : super(key: key);

  final List<CardModel> data;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    // Hitung pemasukan
    final pemasukan = data
        .where((c) => c.category?.toLowerCase() == "income")
        .fold<int>(0, (sum, c) => sum + (c.balance ?? 0));

    // Hitung pengeluaran
    final pengeluaran = data
        .where((c) => c.category?.toLowerCase() == "expense")
        .fold<int>(0, (sum, c) => sum + (c.balance ?? 0));

    final total = pemasukan - pengeluaran;

    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      pinned: true,
      floating: false,
      snap: false,
      toolbarHeight: SizeConfig.blockSizeVertical * 25,
      expandedHeight: SizeConfig.blockSizeVertical * 25,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal * 5,
            vertical: SizeConfig.blockSizeVertical * 2,
          ),
          child: CustomCard(
            color: Colors.deepPurpleAccent,
            total: total,
            pemasukan: pemasukan,
            pengeluaran: pengeluaran,
          ),
        ),
      ),
    );
  }
}
