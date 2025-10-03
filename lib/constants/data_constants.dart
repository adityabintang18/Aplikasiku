import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const List cardConstant = <Map<String, dynamic>>[
  {
    'color': Color(0xFFa587e9),
    'balance': 12480209,
    'cardNumber': 1234567891013901,
    'category': 'income',
  },
  {
    'color': Color(0xFFAE75DA),
    'balance': 21084902,
    'cardNumber': 1234567891011093,
    'category': 'expense',
  },
];

const List<Map<String, dynamic>> menuConstant = [
  {'menu': 'Keuangan', 'icon': FontAwesomeIcons.chartLine},
  {'menu': 'Tabungan', 'icon': FontAwesomeIcons.piggyBank},
  {'menu': 'Agenda', 'icon': FontAwesomeIcons.calendar},
  {'menu': 'Catatan', 'icon': FontAwesomeIcons.stickyNote},
  {'menu': 'To-Do', 'icon': FontAwesomeIcons.tasks},
  {'menu': 'Profil', 'icon': FontAwesomeIcons.user},
];

const List<Map<String, dynamic>> liturgicalConstant = [
  {
    'feast': 'Hari Minggu Adven I',
    'liturgicalColor': 0xFFa587e9,
    'readings': {
      'Bacaan I': 'Yes 63:16b-17,19b; 64:2b-7',
      'Mazmur Tanggapan': 'Mzm 80:2ac,3b,15-16,18-19',
      'Bacaan II': 'Yes 63:16b-17,19b; 64:2b-7',
      'Bait Pengantar Injil': 'Mzm 85:8',
      'Bacaan Injil': 'Mrk 13:33-37',
    },
  },
];

const List<Map<String, dynamic>> transactionConstant = [
  {
    'title': 'Gaji Bulanan',
    'date': '31 Agustus 2025',
    'amount': 5000000,
    'isExpense': false,
  },
  {
    'title': 'Belanja Makanan',
    'date': '01 September 2025',
    'amount': 120000,
    'isExpense': true,
  },
  {
    'title': 'Transportasi',
    'date': '30 Agustus 2025',
    'amount': 25000,
    'isExpense': true,
  },
  {
    'title': 'Gaji Bulanan',
    'date': '31 Agustus 2025',
    'amount': 5000000,
    'isExpense': false,
  },
  {
    'title': 'Belanja Makanan',
    'date': '01 Agustus 2025',
    'amount': 120000,
    'isExpense': true,
  },
  {
    'title': 'Transportasi',
    'date': '30 Agustus 2025',
    'amount': 25000,
    'isExpense': true,
  },
];
