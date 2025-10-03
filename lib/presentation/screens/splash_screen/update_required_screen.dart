import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class UpdateRequiredScreen extends StatelessWidget {
  final String storeUrl;
  final String? message;

  const UpdateRequiredScreen({super.key, required this.storeUrl, this.message});

  Future<void> _openStore() async {
    final uri = Uri.parse(storeUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $storeUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(Icons.system_update, size: 120, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'Pembaruan Diperlukan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message ?? 'Versi baru aplikasi tersedia dan wajib diupdate untuk melanjutkan penggunaan.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openStore,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Update Sekarang'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Exit the app completely
                    SystemNavigator.pop();
                  },
                  child: const Text('Keluar Aplikasi'),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}