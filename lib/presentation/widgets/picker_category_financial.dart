import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../controllers/category_financial_controller.dart';
import '../../config/size_config.dart';
import '../../services/ref_jenis_transaksi.dart';
import '../../models/model.dart';

class PickerCategoryFinancial extends StatefulWidget {
  const PickerCategoryFinancial({super.key});

  @override
  State<PickerCategoryFinancial> createState() =>
      _PickerCategoryFinancialState();
}

class _PickerCategoryFinancialState extends State<PickerCategoryFinancial> {
  List<JenisTransaksiModel> _categories = [];
  bool _isLoading = true;

  // Map nama icon ke IconData
  final Map<String, IconData> _iconNameMap = {
    'house': FontAwesomeIcons.house,
    'briefcase': FontAwesomeIcons.briefcase,
    'utensils': FontAwesomeIcons.utensils,
    'car': FontAwesomeIcons.car,
    'film': FontAwesomeIcons.film,
    'cartShopping': FontAwesomeIcons.cartShopping,
    'piggyBank': FontAwesomeIcons.piggyBank,
    'graduationCap': FontAwesomeIcons.graduationCap,
    'heart': FontAwesomeIcons.heart,
    'bolt': FontAwesomeIcons.bolt,
    'plane': FontAwesomeIcons.plane,
    'mobile': FontAwesomeIcons.mobile,
    'gift': FontAwesomeIcons.gift,
    'music': FontAwesomeIcons.music,
    'basketball': FontAwesomeIcons.basketball,
    'book': FontAwesomeIcons.book,
    'dumbbell': FontAwesomeIcons.dumbbell,
    'laptop': FontAwesomeIcons.laptop,
    'burger': FontAwesomeIcons.burger,
    'tshirt': FontAwesomeIcons.tshirt,
    'money': FontAwesomeIcons.moneyBill
  };

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final data = await RefService.getJenisTransaksi(context);
      setState(() {
        _categories = data;
        _isLoading = false;

        if (_categories.isNotEmpty) {
          // Set nama dan id kategori terpilih di controller
          CategoryFinancialController.selectedCategory.value =
              _categories.first.nama;
          CategoryFinancialController.selectedCategoryId.value =
              _categories.first.id;
          CategoryFinancialController.selectedCategoryName.value =
              _categories.first.nama;
        }
      });
    } catch (e) {
      print("Error fetch jenis transaksi: $e");
      setState(() => _isLoading = false);
    }
  }

  void _showAddCategoryDialog() {
    final labelController = TextEditingController();
    String? selectedIconName;
    final iconSearchController = TextEditingController();

    final List<Map<String, dynamic>> fontAwesomeIcons = [
      {'icon': FontAwesomeIcons.house, 'name': 'house'},
      {'icon': FontAwesomeIcons.briefcase, 'name': 'briefcase'},
      {'icon': FontAwesomeIcons.utensils, 'name': 'utensils'},
      {'icon': FontAwesomeIcons.car, 'name': 'car'},
      {'icon': FontAwesomeIcons.film, 'name': 'film'},
      {'icon': FontAwesomeIcons.cartShopping, 'name': 'cartShopping'},
      {'icon': FontAwesomeIcons.piggyBank, 'name': 'piggyBank'},
      {'icon': FontAwesomeIcons.graduationCap, 'name': 'graduationCap'},
      {'icon': FontAwesomeIcons.heart, 'name': 'heart'},
      {'icon': FontAwesomeIcons.bolt, 'name': 'bolt'},
      {'icon': FontAwesomeIcons.plane, 'name': 'plane'},
      {'icon': FontAwesomeIcons.mobile, 'name': 'mobile'},
      {'icon': FontAwesomeIcons.gift, 'name': 'gift'},
      {'icon': FontAwesomeIcons.music, 'name': 'music'},
      {'icon': FontAwesomeIcons.basketball, 'name': 'basketball'},
      {'icon': FontAwesomeIcons.book, 'name': 'book'},
      {'icon': FontAwesomeIcons.dumbbell, 'name': 'dumbbell'},
      {'icon': FontAwesomeIcons.laptop, 'name': 'laptop'},
      {'icon': FontAwesomeIcons.burger, 'name': 'burger'},
      {'icon': FontAwesomeIcons.tshirt, 'name': 'tshirt'},
      {'icon': FontAwesomeIcons.moneyBill, 'name': 'money'},
    ];

    List<Map<String, dynamic>> filteredIcons = List.from(fontAwesomeIcons);

    showDialog(
      context: this.context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Tambah Kategori"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: labelController,
                      decoration:
                          const InputDecoration(labelText: "Nama Kategori"),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: iconSearchController,
                      decoration: const InputDecoration(
                        labelText: "Cari Icon",
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (query) {
                        setStateDialog(() {
                          filteredIcons = fontAwesomeIcons
                              .where((iconMap) => iconMap['name']
                                  .toString()
                                  .toLowerCase()
                                  .contains(query.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Tambahkan constraint
                    SizedBox(
                      height: 250,
                      width: double.maxFinite,
                      child: GridView.count(
                        crossAxisCount: 5,
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          for (var iconMap in filteredIcons)
                            GestureDetector(
                              onTap: () {
                                setStateDialog(() {
                                  selectedIconName = iconMap['name'] as String;
                                });
                              },
                              child: CircleAvatar(
                                backgroundColor:
                                    selectedIconName == iconMap['name']
                                        ? Colors.deepPurpleAccent
                                        : Colors.grey[200],
                                child: Icon(
                                  iconMap['icon'] as IconData,
                                  color: selectedIconName == iconMap['name']
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (labelController.text.isNotEmpty &&
                        selectedIconName != null) {
                      // Tambahkan argumen jenisKategori, misal default "Lainnya"
                      final success = await RefService.addJenisTransaksi(
                        this.context,
                        labelController.text,
                        selectedIconName!,
                        "Lainnya", // atau ganti sesuai kebutuhan aplikasi
                      );
                      if (success) {
                        Navigator.of(dialogContext).pop();
                        _fetchCategories();
                      }
                    }
                  },
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      height: SizeConfig.blockSizeVertical * 15,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var cat in _categories) ...[
              _buildCategory(_getIconFromName(cat.icon), cat.nama, cat.id),
              const SizedBox(width: 16), // kasih jarak antar kategori
            ],
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  // Ambil IconData dari nama icon (string)
  IconData _getIconFromName(String? iconName) {
    if (iconName == null) return FontAwesomeIcons.folder;
    return _iconNameMap[iconName] ?? FontAwesomeIcons.folder;
  }

  Widget _buildCategory(IconData icon, String label, int id) {
    return ValueListenableBuilder<int?>(
      valueListenable: CategoryFinancialController.selectedCategoryId,
      builder: (context, selectedId, _) {
        final bool isSelected = selectedId == id;

        return GestureDetector(
          onTap: () {
            CategoryFinancialController.selectedCategory.value = label;
            CategoryFinancialController.selectedCategoryName.value = label;
            CategoryFinancialController.selectedCategoryId.value = id;
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                child: Icon(icon,
                    color: isSelected ? Colors.deepPurpleAccent : Colors.white,
                    size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showAddCategoryDialog,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(Icons.add, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            "Tambah",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
