import 'package:flutter/material.dart';
import '../../models/model.dart';
import 'liturgical_calendar.dart';
import '../../config/size_config.dart';
import '../screens/liturgical_detail/liturgical_detail_page.dart';

class ListViewDashboard extends StatefulWidget {
  const ListViewDashboard({Key? key, required this.data}) : super(key: key);
  final List<CalendarDay> data;

  @override
  State<ListViewDashboard> createState() => _ListViewDashboardState();
}

class _ListViewDashboardState extends State<ListViewDashboard> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollButtons();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _updateScrollButtons();
  }

  void _updateScrollButtons() {
    if (!_scrollController.hasClients) return;

    setState(() {
      _canScrollLeft = _scrollController.offset > 0;
      _canScrollRight =
          _scrollController.offset < _scrollController.position.maxScrollExtent;
    });
  }

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = SizeConfig.blockSizeHorizontal * 5; // lebih lega
    double verticalPadding = SizeConfig.blockSizeVertical * 0; // lebih lega
    double itemSpacing = SizeConfig.blockSizeHorizontal * 3; // jarak antar card
    double screenWidth = MediaQuery.of(context).size.width;

    int itemCount = widget.data.length;
    double totalSpacing = itemSpacing * (itemCount - 1);
    double availableWidth =
        screenWidth - (horizontalPadding * 2) - totalSpacing;
    double itemWidth = availableWidth / itemCount;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: SizedBox(
        height: SizeConfig.blockSizeVertical * 23, // tambah tinggi sedikit
        child: Stack(
          children: [
            ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.data.length,
              itemBuilder: (context, index) {
                final item = widget.data[index];

                double leftMargin = index == 0 ? 0 : itemSpacing / 2;
                double rightMargin =
                    index == widget.data.length - 1 ? 0 : itemSpacing / 2;

                bool isWhiteBackground =
                    item.liturgicalColor.value == 0xFFFFFFFF;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: itemWidth,
                  margin: EdgeInsets.only(left: leftMargin, right: rightMargin),
                  padding: EdgeInsets.all(
                      SizeConfig.blockSizeHorizontal * 2), // padding dalam card
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(SizeConfig.blockWidth * 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: SizeConfig.blockWidth * 4,
                        offset: Offset(0, SizeConfig.blockHeight * 1.2),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.black.withOpacity(0.07),
                      width: 1.1,
                    ),
                    color: item.liturgicalColor.withOpacity(0.93),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(SizeConfig.blockWidth * 4),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LiturgicalDetailPage(
                              feast: item.perayaan,
                              readings: {
                                for (var bacaan in item.bacaan)
                                  bacaan.text: bacaan.href
                              },
                              color: widget.data[index].liturgicalColor,
                            ),
                          ),
                        );
                      },
                      borderRadius:
                          BorderRadius.circular(SizeConfig.blockWidth * 4),
                      splashColor: Colors.white.withOpacity(0.13),
                      highlightColor: Colors.white.withOpacity(0.07),
                      child: LiturgicalTodayCard(
                        feast: item.perayaan,
                        readings: {
                          for (var bacaan in item.bacaan)
                            bacaan.text: bacaan.href
                        },
                        color: item.liturgicalColor,
                        textColor: isWhiteBackground ? Colors.black : null,
                      ),
                    ),
                  ),
                );
              },
            ),
            if (_canScrollLeft)
              Positioned(
                left: 0,
                top: SizeConfig.blockSizeVertical *
                    11, // posisi panah lebih rapi
                child: _buildArrow(Icons.chevron_left),
              ),
            if (_canScrollRight)
              Positioned(
                right: 0,
                top: SizeConfig.blockSizeVertical * 11,
                child: _buildArrow(Icons.chevron_right),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrow(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.black.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Icon(icon, color: Colors.black87, size: 22),
    );
  }
}
