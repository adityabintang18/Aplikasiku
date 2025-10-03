import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasiku/presentation/widgets/custom_button.dart';
import 'package:aplikasiku/presentation/widgets/custom_text_field.dart';
import 'package:aplikasiku/presentation/widgets/toggle_button.dart';
import 'sign_up_screen.dart';
import 'package:aplikasiku/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:aplikasiku/controllers/navigation_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isSignIn = true;
  bool _isEmail = true;
  bool _isLoading = false;
  String username = '';
  String password = '';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final LocalAuthentication auth = LocalAuthentication();
  bool _fingerEnabled = false;
  bool _bioSupported = false;

  @override
  void initState() {
    super.initState();
    _initBiometricState();
  }

  Future<void> _initBiometricState() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('fingerprint_enabled') ?? false;
    bool supported = false;
    try {
      final canCheck = await auth.canCheckBiometrics;
      final deviceSupported = await auth.isDeviceSupported();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFf1f2f6),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _topButton(context),
              const SizedBox(height: 70),
              _signInText(),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _emailInput(),
                    const SizedBox(height: 20),
                    _passwordInput(),
                  ],
                ),
              ),
              _forgetPasswordRow(),
              const SizedBox(height: 40),
              _signInButton(context),
              const SizedBox(height: 40),
              if (_fingerEnabled && _bioSupported) _fingerText(context),
            ],
          ),
        ),
      ),
    );
  }

  Center _fingerText(BuildContext context) {
    return Center(
      child: Column(
        children: [
          IconButton(
            icon: const Icon(
              Icons.fingerprint,
              size: 50,
              color: Colors.deepPurpleAccent,
            ),
            onPressed: () async {
              await _authenticateWithFingerprint(context);
            },
          ),
          const SizedBox(height: 10),
          Text(
            'Pakai sidik jari?',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _authenticateWithFingerprint(BuildContext context) async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Perangkat tidak mendukung sidik jari."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      bool isAuthenticated = await auth.authenticate(
        localizedReason: 'Autentikasi untuk masuk ke aplikasi',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        final prefs = await SharedPreferences.getInstance();
        final savedEmail = prefs.getString('last_user_email');
        final savedPassword = prefs.getString('last_user_password');

        if (savedEmail == null || savedPassword == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Data email atau password untuk sidik jari tidak ditemukan."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          _isLoading = true;
        });

        // Login ulang menggunakan email dan password yang tersimpan
        final result = await AuthService.login(
          username: savedEmail,
          password: savedPassword,
        );

        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          final data = result['data'];
          final token = data['token'];

          await prefs.setString('token', token);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Autentikasi sidik jari berhasil!"),
              backgroundColor: Colors.green,
            ),
          );

          // Arahkan ke halaman beranda menggunakan NavigationMenu (GetX)
          // Menggunakan Get.offAll untuk menghapus semua route sebelumnya dan langsung ke NavigationMenu
          Get.offAll(() => const NavigationMenu());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'].toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Autentikasi sidik jari gagal."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on PlatformException catch (e) {
      print("Error saat autentikasi: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: ${e.message}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  CustomButton _signInButton(BuildContext context) {
    return CustomButton(
      text: 'Masuk',
      isLoading: _isLoading,
      onPressed: _signIn,
    );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    username = _emailController.text.trim();
    password = _passwordController.text.trim();

    final result = await AuthService.login(
      username: username,
      password: password,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final data = result['data'];
      final token = data['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('last_user_email', username);
      await prefs.setString('last_user_password', password);

      // Tambahkan pemberitahuan masuk berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Masuk berhasil!"),
          backgroundColor: Colors.green,
        ),
      );

      // Paksa ke halaman beranda (clear semua route sebelumnya)
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'].toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  CustomTextField _emailInput() {
    return CustomTextField(
      label: _isEmail ? 'Email' : 'Nomor Telepon',
      placeholder: _isEmail ? 'Masukkan email' : 'Masukkan no telepon',
      controller: _emailController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return _isEmail ? "Email wajib diisi" : "Nomor telepon wajib diisi";
        }
        if (_isEmail &&
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return "Format email tidak valid";
        }
        return null;
      },
    );
  }

  CustomTextField _passwordInput() {
    return CustomTextField(
      label: 'Kata Sandi',
      isPassword: true,
      placeholder: 'Masukkan kata sandi',
      controller: _passwordController,
      validator: (value) {
        if (value == null || value.isEmpty) return "Password wajib diisi";
        if (value.length < 6) return "Password minimal 6 karakter";
        return null;
      },
    );
  }

  Row _forgetPasswordRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(
            'Lupa Kata Sandi?',
            style: GoogleFonts.poppins(
                color: Colors.black, fontWeight: FontWeight.w400, fontSize: 12),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isEmail = !_isEmail;
            });
          },
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(
            _isEmail ? 'Masuk dengan no telepon' : 'Masuk dengan email',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Column _signInText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang!',
          style: GoogleFonts.poppins(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 5),
        Text(
          'Silahkan masuk untuk melanjutkan',
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey),
        ),
      ],
    );
  }

  Container _topButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: ToggleButton(
              text: 'Masuk',
              isSelected: _isSignIn,
              onPressed: () => setState(() => _isSignIn = true),
            ),
          ),
          Expanded(
            child: ToggleButton(
              text: 'Daftar',
              isSelected: !_isSignIn,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        const SignUpScreen(),
                    transitionDuration: const Duration(milliseconds: 400),
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
