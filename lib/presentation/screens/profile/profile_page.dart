import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/size_config.dart';
import '../../../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _fingerEnabled = false;
  bool _bioSupported = false;
  final TextEditingController _nameController =
      TextEditingController(text: 'Bintang Pratama');
  final TextEditingController _emailController =
      TextEditingController(text: 'bintang@example.com');
  final TextEditingController _phoneController =
      TextEditingController(text: '+62 812 3456 7890');
  final TextEditingController _dateController =
      TextEditingController(text: '1 Januari 2024');
  bool _isEditing = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _image = File(image.path));
    }
  }

  @override
  void initState() {
    super.initState();
    _initBiometricSettings();
  }

  Future<void> _initBiometricSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('fingerprint_enabled') ?? false;
    bool supported = false;
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final deviceSupported = await _localAuth.isDeviceSupported();
      supported = canCheck && deviceSupported;
    } catch (_) {
      supported = false;
    }
    if (mounted) {
      setState(() {
        _fingerEnabled = enabled && supported;
        _bioSupported = supported;
      });
    }
  }

  Future<void> _toggleFingerprint(bool value) async {
    if (!_bioSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perangkat tidak mendukung biometrik')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();

    if (value) {
      try {
        final ok = await _localAuth.authenticate(
          localizedReason: 'Aktifkan autentikasi sidik jari',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
        if (!ok) return;
      } catch (e) {
        return;
      }
      final lastEmail = prefs.getString('last_user_email');
      String? lastPassword = prefs.getString('last_user_password');

      if (lastPassword == null) {
        lastPassword = prefs.getString('fingerprint_user_password');
        debugPrint(
            'DEBUG fingerprint: last_user_password is null, fallback to fingerprint_user_password: $lastPassword');
      }

      if (lastPassword == null) {
        debugPrint(
            'WARNING: last_user_password is still null! Pastikan password sudah disimpan saat login.');
      }

      debugPrint(
          'DEBUG fingerprint: lastEmail=$lastEmail, lastPassword=$lastPassword');
      if (lastEmail != null) {
        await prefs.setString('fingerprint_user_email', lastEmail);
      }
      if (lastPassword != null) {
        await prefs.setString('fingerprint_user_password', lastPassword);
      }
    } else {
      await prefs.remove('fingerprint_user_email');
      await prefs.remove('fingerprint_user_password');
    }

    await prefs.setBool('fingerprint_enabled', value);
    if (mounted) setState(() => _fingerEnabled = value);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('last_page_index');
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    // Tambahkan feedback jika perlu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Berhasil logout, silakan login kembali.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: SizeConfig.blockSizeVertical * 3),
            _buildForm(),
            SizedBox(height: SizeConfig.blockSizeVertical * 4),
            _buildAccountActions(),
            SizedBox(height: SizeConfig.blockSizeVertical * 4),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF6C5CE7),
            Color(0xFFA29BFE),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          right: SizeConfig.blockSizeHorizontal * 6,
          left: SizeConfig.blockSizeHorizontal * 6,
          top: SizeConfig.blockSizeVertical * 7,
          bottom: SizeConfig.blockSizeVertical * 3,
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: SizeConfig.blockSizeHorizontal * 25,
                  height: SizeConfig.blockSizeHorizontal * 25,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: SizeConfig.blockSizeHorizontal * 12.5,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : const AssetImage('assets/images/profile.png')
                            as ImageProvider,
                  ),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFF6C5CE7),
                        radius: 18,
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            Text(
              _nameController.text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: SizeConfig.blockSizeHorizontal * 5.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
            Text(
              _emailController.text,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: SizeConfig.blockSizeHorizontal * 3.8,
              ),
            ),
            SizedBox(height: SizeConfig.blockSizeVertical * 1),
            InkWell(
              onTap: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 4,
                  vertical: SizeConfig.blockSizeVertical * 1,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Text(
                  _isEditing ? 'Batal' : 'Edit',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Form tanpa kata "Profil"
  Widget _buildForm() {
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 4),
      padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi',
            style: GoogleFonts.poppins(
              color: const Color(0xFF2C3E50),
              fontSize: SizeConfig.blockSizeHorizontal * 4.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          _buildEditableField(
            label: 'Nama Lengkap',
            controller: _nameController,
            icon: FontAwesomeIcons.user,
          ),
          _buildEditableField(
            label: 'Email',
            controller: _emailController,
            icon: FontAwesomeIcons.envelope,
          ),
          _buildEditableField(
            label: 'Nomor Telepon',
            controller: _phoneController,
            icon: FontAwesomeIcons.phone,
          ),
          _buildEditableField(
            label: 'Tanggal Bergabung',
            controller: _dateController,
            icon: FontAwesomeIcons.calendar,
            enabled: false,
          ),
          if (_isEditing)
            Padding(
              padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: SizeConfig.blockSizeHorizontal * 4),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Perubahan berhasil disimpan!'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Simpan',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 2),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2.5),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(
              icon,
              color: const Color(0xFF6C5CE7),
              size: SizeConfig.blockSizeHorizontal * 4,
            ),
          ),
          SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
          Expanded(
            child: _isEditing && enabled
                ? TextField(
                    controller: controller,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2C3E50),
                      fontSize: SizeConfig.blockSizeHorizontal * 3.8,
                    ),
                    decoration: InputDecoration(
                      labelText: label,
                      labelStyle: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: SizeConfig.blockSizeHorizontal * 3.2,
                      ),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: SizeConfig.blockSizeHorizontal * 3.2,
                        ),
                      ),
                      Text(
                        controller.text,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2C3E50),
                          fontSize: SizeConfig.blockSizeHorizontal * 3.8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFingerprintToggleItem(),
          const Divider(height: 1),
          _buildMenuItem('Keluar', FontAwesomeIcons.signOutAlt, _logout,
              isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildFingerprintToggleItem() {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2.5),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fingerprint, color: Color(0xFF6C5CE7)),
          ),
          SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gunakan Sidik Jari',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF2C3E50),
                    fontSize: SizeConfig.blockSizeHorizontal * 3.8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _bioSupported
                      ? 'Aktifkan untuk login lebih cepat'
                      : 'Biometrik tidak didukung perangkat',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: SizeConfig.blockSizeHorizontal * 3.0,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _fingerEnabled,
            onChanged: _bioSupported ? _toggleFingerprint : null,
            activeColor: const Color(0xFF6C5CE7),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap,
      {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2.5),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : const Color(0xFF6C5CE7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FaIcon(
                icon,
                color: isDestructive ? Colors.red : const Color(0xFF6C5CE7),
                size: SizeConfig.blockSizeHorizontal * 4,
              ),
            ),
            SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: isDestructive ? Colors.red : const Color(0xFF2C3E50),
                  fontSize: SizeConfig.blockSizeHorizontal * 3.8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            FaIcon(
              FontAwesomeIcons.chevronRight,
              color: Colors.grey[400],
              size: SizeConfig.blockSizeHorizontal * 3.5,
            ),
          ],
        ),
      ),
    );
  }
}
