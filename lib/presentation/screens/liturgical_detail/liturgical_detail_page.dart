import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../config/size_config.dart';
import '../../../services/calender_liturgical_service.dart';
import '../../../models/model.dart';

class LiturgicalDetailPage extends StatelessWidget {
  final String feast;
  final Map<String, String> readings;
  final Color color;

  const LiturgicalDetailPage({
    Key? key,
    required this.feast,
    required this.readings,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final String today =
        DateFormat('EEEE, d MMMM y', 'id_ID').format(DateTime.now());

    // Deteksi apakah background putih
    final bool isWhiteBackground = color.value == 0xFFFFFFFF;
    final Color mainTextColor = isWhiteBackground ? Colors.black : Colors.white;
    final Color secondaryTextColor =
        isWhiteBackground ? Colors.black54 : Colors.white70;
    final Color containerBg = isWhiteBackground
        ? Colors.black.withOpacity(0.04)
        : Colors.white.withOpacity(0.2);
    final Color containerBg2 = isWhiteBackground
        ? Colors.black.withOpacity(0.02)
        : Colors.white.withOpacity(0.1);
    final Color containerBg3 = isWhiteBackground
        ? Colors.black.withOpacity(0.01)
        : Colors.white.withOpacity(0.05);
    final Color borderColor = isWhiteBackground
        ? Colors.black.withOpacity(0.15)
        : Colors.white.withOpacity(0.2);

    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: mainTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Kalender Liturgi',
          style: GoogleFonts.poppins(
            color: mainTextColor,
            fontSize: SizeConfig.blockSizeHorizontal * 4.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
              decoration: BoxDecoration(
                color: containerBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal',
                    style: GoogleFonts.poppins(
                      color: secondaryTextColor,
                      fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockSizeVertical * 1),
                  Text(
                    today,
                    style: GoogleFonts.poppins(
                      color: mainTextColor,
                      fontSize: SizeConfig.blockSizeHorizontal * 5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: SizeConfig.blockSizeVertical * 3),

            // Feast Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
              decoration: BoxDecoration(
                color: containerBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pesta/Peringatan',
                    style: GoogleFonts.poppins(
                      color: secondaryTextColor,
                      fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockSizeVertical * 1),
                  Text(
                    feast,
                    style: GoogleFonts.poppins(
                      color: mainTextColor,
                      fontSize: SizeConfig.blockSizeHorizontal * 4.8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: SizeConfig.blockSizeVertical * 3),

            // Readings Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
              decoration: BoxDecoration(
                color: containerBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bacaan Liturgi',
                    style: GoogleFonts.poppins(
                      color: secondaryTextColor,
                      fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockSizeVertical * 2),
                  ...readings.entries.map(
                    (entry) => LiturgicalReadingAyatCard(
                      title: entry.key,
                      href: entry.value,
                      mainTextColor: mainTextColor,
                      secondaryTextColor: secondaryTextColor,
                      containerBg: containerBg,
                      containerBg2: containerBg2,
                      containerBg3: containerBg3,
                      borderColor: borderColor,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: SizeConfig.blockSizeVertical * 4),
          ],
        ),
      ),
    );
  }
}

class LiturgicalReadingAyatCard extends StatefulWidget {
  final String title;
  final String href;
  final Color mainTextColor;
  final Color secondaryTextColor;
  final Color containerBg;
  final Color containerBg2;
  final Color containerBg3;
  final Color borderColor;

  const LiturgicalReadingAyatCard({
    Key? key,
    required this.title,
    required this.href,
    required this.mainTextColor,
    required this.secondaryTextColor,
    required this.containerBg,
    required this.containerBg2,
    required this.containerBg3,
    required this.borderColor,
  }) : super(key: key);

  @override
  State<LiturgicalReadingAyatCard> createState() =>
      _LiturgicalReadingAyatCardState();
}

class _LiturgicalReadingAyatCardState extends State<LiturgicalReadingAyatCard> {
  String? ayat;
  bool loading = false;
  String? error;

  final CalenderLiturgicalService _service =
      CalenderLiturgicalService(baseUrl: "http://192.168.1.10:8000");

  @override
  void initState() {
    super.initState();
    fetchAyat();
  }

  Future<void> fetchAyat() async {
    // Ambil query `q` dari href
    String? paramQ;
    try {
      final uri = Uri.tryParse(widget.href);
      if (uri != null && uri.queryParameters.containsKey('q')) {
        paramQ = uri.queryParameters['q'];
      } else {
        // fallback parsing manual
        final qIndex = widget.href.indexOf('q=');
        if (qIndex != -1) {
          paramQ = widget.href.substring(qIndex + 2);
          final andIdx = paramQ.indexOf('&');
          if (andIdx != -1) {
            paramQ = paramQ.substring(0, andIdx);
          }
        }
      }
    } catch (_) {
      setState(() => error = "Link bacaan tidak valid");
      return;
    }

    if (paramQ == null || paramQ.isEmpty) {
      setState(() => error = "Ayat tidak tersedia");
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final hasil = await _service.fetchAyat(context, paramQ);

      setState(() {
        ayat = hasil.isNotEmpty
            ? hasil.map((e) => e.text.isNotEmpty ? e.text : "-").join('\n\n')
            : "Ayat tidak ditemukan";
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = "Terjadi kesalahan: $e";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 2),
      padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 3),
      decoration: BoxDecoration(
        color: widget.containerBg2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul Bacaan
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 3,
              vertical: SizeConfig.blockSizeVertical * 0.8,
            ),
            decoration: BoxDecoration(
              color: widget.containerBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.title,
              style: GoogleFonts.poppins(
                color: widget.mainTextColor,
                fontSize: SizeConfig.blockSizeHorizontal * 3.8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
          // Ayat Bacaan
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 3),
            decoration: BoxDecoration(
              color: widget.containerBg2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: loading
                ? Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: widget.mainTextColor,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : error != null
                    ? Text(
                        error!,
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: SizeConfig.blockSizeHorizontal * 3.6,
                        ),
                      )
                    : Text(
                        ayat ?? "-",
                        style: GoogleFonts.poppins(
                          color: widget.mainTextColor,
                          fontSize: SizeConfig.blockSizeHorizontal * 3.8,
                          height: 1.6,
                          letterSpacing: 0.3,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
