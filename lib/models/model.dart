import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class CardModel {
  Color? color;
  int? balance;
  int? cardNumber;
  String? category;

  CardModel({
    required this.color,
    required this.balance,
    required this.cardNumber,
    required this.category,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      color: json['color'],
      balance: json['balance'],
      cardNumber: json['cardNumber'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color': color?.toARGB32(),
      'balance': balance,
      'cardNumber': cardNumber,
      'category': category,
    };
  }
}

class MenuModel {
  String? menu;
  IconData? icon;

  MenuModel({this.menu, this.icon});

  static IconData? _mapStringToIcon(String? iconName) {
    switch (iconName) {
      case 'finance':
        return FontAwesomeIcons.dollarSign;
      case 'savings':
        return FontAwesomeIcons.piggyBank;
      case 'calendar':
        return FontAwesomeIcons.calendarDays;
      case 'note':
        return FontAwesomeIcons.noteSticky;
      case 'tasks':
        return FontAwesomeIcons.listCheck;
      case 'history':
        return FontAwesomeIcons.clockRotateLeft;
      default:
        return FontAwesomeIcons.circle;
    }
  }

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      menu: json['menu'] as String?,
      icon: json['icon'] as IconData?,
    );
  }
}

class LiturgicalModel {
  final String text;
  final String href;
  final String param;

  LiturgicalModel({
    required this.text,
    required this.href,
    required this.param,
  });

  factory LiturgicalModel.fromJson(Map<String, dynamic> json) {
    return LiturgicalModel(
      text: json['text'] ?? '',
      href: json['href'] ?? '',
      param: json['param'] ?? '',
    );
  }

  static List<LiturgicalModel> fromDynamic(dynamic data) {
    if (data == null) {
      return [];
    } else if (data is List) {
      // Jika sudah List, pastikan setiap elemen diparse
      return data
          .where((e) => e != null)
          .map((e) => e is LiturgicalModel
              ? e
              : (e is Map<String, dynamic>
                  ? LiturgicalModel.fromJson(e)
                  : null))
          .whereType<LiturgicalModel>()
          .toList();
    } else if (data is Map<String, dynamic>) {
      // Jika Map, bungkus ke List
      return [LiturgicalModel.fromJson(data)];
    } else if (data is LiturgicalModel) {
      return [data];
    }
    // Jika tipe lain, kembalikan list kosong
    return [];
  }
}

class CalendarDay {
  final String tanggal;
  final String perayaan;
  final List<LiturgicalModel> bacaan;
  final String warna;

  CalendarDay({
    required this.tanggal,
    required this.perayaan,
    required this.bacaan,
    required this.warna,
  });

  factory CalendarDay.fromJson(Map<String, dynamic> json) {
    final bacaanJson = json['bacaan'] as List? ?? [];
    return CalendarDay(
      tanggal: json['tanggal'] ?? '',
      perayaan: json['perayaan'] ?? '',
      bacaan: bacaanJson
          .where((e) => e != null)
          .map((e) => LiturgicalModel.fromJson(e))
          .toList(),
      warna: json['warna']?.toString() ?? '',
    );
  }

  Color get liturgicalColor => parseColorFromString(warna);
}

Color parseColorFromString(String? raw) {
  if (raw == null) return Colors.grey;
  String s = raw.trim();

  if (s.startsWith('0x') || s.startsWith('0X')) {
    try {
      return Color(int.parse(s));
    } catch (_) {
      return Colors.grey;
    }
  }

  if (s.startsWith('#')) {
    s = s.substring(1);
    if (s.length == 6) s = 'FF$s'; // tambahkan alpha jika cuma RGB
    try {
      return Color(int.parse(s, radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  return Colors.grey;
}

class TransactionModel {
  final String title;
  final DateTime date;
  final int amount;
  final bool isExpense;

  TransactionModel({
    required this.title,
    required this.date,
    required this.amount,
    required this.isExpense,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'];

    // Coba parse tanggal dengan beberapa format, fallback ke null jika gagal
    DateTime? parsedDate;
    List<String> formats = [
      "dd MMMM yyyy",
      "yyyy-MM-dd",
      "d MMMM yyyy",
      "dd-MM-yyyy",
      "d-M-yyyy",
    ];
    for (var fmt in formats) {
      try {
        parsedDate = DateFormat(fmt, "id_ID").parseStrict(rawDate);
        break;
      } catch (_) {}
    }
    if (parsedDate == null) {
      // fallback: coba parse default DateTime
      try {
        parsedDate = DateTime.parse(rawDate);
      } catch (_) {
        parsedDate = DateTime.now();
      }
    }

    return TransactionModel(
      title: json['title'],
      date: parsedDate,
      amount: json['amount'],
      isExpense: json['isExpense'],
    );
  }
}

class Note {
  final int? id;
  final String? judul;
  final String? content;
  final String? tanggalCatatan;

  Note({
    this.id,
    this.judul,
    this.content,
    this.tanggalCatatan,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as int?,
      judul: json['judul'] as String?,
      content: json['content'] as String?,
      tanggalCatatan: json['tanggal_catatan'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'content': content,
      'tanggal_catatan': tanggalCatatan,
    };
  }
}

class TransaksiModel {
  final int? id;
  final String title;
  final int? category;
  final String? nameCategory;
  final int? jenisKategori;
  final String? nameKategori;
  final DateTime date;
  final int amount;
  final bool isIncome;
  final String? description;
  final String? photoPath;
  final String? photoUrl;

  TransaksiModel({
    this.id,
    required this.title,
    this.category,
    this.nameCategory,
    this.jenisKategori,
    this.nameKategori,
    required this.date,
    required this.amount,
    required this.isIncome,
    this.description,
    this.photoPath,
    this.photoUrl,
  });

  TransaksiModel copyWith({
    int? id,
    String? title,
    int? category,
    String? nameCategory,
    int? jenisKategori,
    String? nameKategori,
    DateTime? date,
    int? amount,
    bool? isIncome,
    String? description,
    String? photoPath,
    String? photoUrl,
  }) {
    return TransaksiModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      nameCategory: nameCategory ?? this.nameCategory,
      jenisKategori: jenisKategori ?? this.jenisKategori,
      nameKategori: nameKategori ?? this.nameKategori,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      isIncome: isIncome ?? this.isIncome,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    // Penyesuaian parsing date agar lebih fleksibel
    DateTime? parsedDate;
    final rawDate = json['date'];
    if (rawDate is String) {
      try {
        parsedDate = DateTime.parse(rawDate);
      } catch (_) {
        parsedDate = DateTime.now();
      }
    } else if (rawDate is int) {
      // Jika timestamp (milisecond)
      parsedDate = DateTime.fromMillisecondsSinceEpoch(rawDate);
    } else {
      parsedDate = DateTime.now();
    }

    return TransaksiModel(
      id: json['id'] is int
          ? json['id'] as int
          : (json['id'] is String ? int.tryParse(json['id']) : null),
      title: json['title'] as String,
      category: json['category'] as int?,
      nameCategory: json['nama_kategori'] as String?,
      jenisKategori: json['jenis_kategori'] as int?,
      nameKategori: json['nama_jenis_kategori'] as String?,
      date: parsedDate,
      amount: json['amount'] is int
          ? json['amount'] as int
          : int.tryParse(json['amount'].toString().split('.').first) ?? 0,
      isIncome: json['is_income'] is bool
          ? json['is_income'] as bool
          : (json['isIncome'] is bool
              ? json['isIncome'] as bool
              : (json['is_income'] is int
                  ? (json['is_income'] == 1)
                  : (json['isIncome'] is int
                      ? (json['isIncome'] == 1)
                      : (json['is_income'] is String
                          ? (json['is_income'].toString().toLowerCase() ==
                                  'true' ||
                              json['is_income'].toString() == '1')
                          : (json['isIncome'] is String
                              ? (json['isIncome'].toString().toLowerCase() ==
                                      'true' ||
                                  json['isIncome'].toString() == '1')
                              : false))))),
      description: json['description'] as String?,
      photoPath: json['photo_path'] as String? ?? json['photoPath'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'jenis_kategori': jenisKategori,
      'date': date.toIso8601String(),
      'amount': amount,
      'is_income': isIncome,
      'description': description,
      'photoPath': photoPath,
      // photo_url hanya berasal dari server; tidak perlu dikirim saat create
    };
  }
}

class JenisTransaksiModel {
  final int id;
  final String nama;
  final String? icon;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  JenisTransaksiModel({
    required this.id,
    required this.nama,
    this.icon,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory JenisTransaksiModel.fromJson(Map<String, dynamic> json) {
    int? userId;
    if (json.containsKey('user_id')) {
      if (json['user_id'] is int) {
        userId = json['user_id'];
      } else if (json['user_id'] != null) {
        userId = int.tryParse(json['user_id'].toString());
      }
    }

    DateTime? createdAt;
    if (json['created_at'] != null) {
      try {
        createdAt = DateTime.parse(json['created_at']);
      } catch (_) {}
    }
    DateTime? updatedAt;
    if (json['updated_at'] != null) {
      try {
        updatedAt = DateTime.parse(json['updated_at']);
      } catch (_) {}
    }

    return JenisTransaksiModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      nama: json['nama']?.toString() ?? '',
      icon: json['icon']?.toString(),
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'icon': icon,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class KategoriModel {
  final int id;
  final String nama;
  final String? deskripsi;

  KategoriModel({required this.id, required this.nama, this.deskripsi});

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    return KategoriModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      nama: json['nama']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
    };
  }
}
