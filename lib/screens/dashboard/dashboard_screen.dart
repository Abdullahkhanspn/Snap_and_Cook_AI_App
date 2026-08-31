import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../core/constants/colors.dart';

final selectedImageProvider = StateProvider<File?>((ref) => null);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _pickImage(WidgetRef ref, ImageSource source, BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      ref.read(selectedImageProvider.notifier).state = File(pickedFile.path);
      context.push('/result');
    }
  }

  Future<void> _logout(WidgetRef ref, BuildContext context) async {
    await ref.read(authServiceProvider).signOut();
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Hero(
          tag: 'app_logo',
          child: Image.asset('cookandsnaplogo.jpeg', height: 40),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_rounded, size: 30, color: AppColors.primary),
            onPressed: () => context.push('/setup-profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
            onPressed: () => _logout(ref, context),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        color: Colors.white,
        child: profileAsync.when(
          data: (profile) => SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi Chef ${profile?.fullName.split(' ')[0] ?? 'Friend'}! 👋',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'What tasty ingredients do we have today?',
                  style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      _ActionButton(
                        icon: Icons.camera_alt_rounded,
                        label: 'Snap a Photo',
                        subtitle: 'Use your camera',
                        color: AppColors.primary,
                        onTap: () => _pickImage(ref, ImageSource.camera, context),
                      ),
                      const SizedBox(height: 24),
                      _ActionButton(
                        icon: Icons.photo_library_rounded,
                        label: 'Pick from Gallery',
                        subtitle: 'Upload an image',
                        color: AppColors.secondary,
                        onTap: () => _pickImage(ref, ImageSource.gallery, context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                _buildTipCard(context),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildTipCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_rounded, color: AppColors.secondary, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cooking Tip!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Snap a clear photo of your vegetables for the best recipe ideas!',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
