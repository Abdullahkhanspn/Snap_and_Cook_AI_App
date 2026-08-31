import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../core/constants/colors.dart';

class SetupProfileScreen extends ConsumerStatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  ConsumerState<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends ConsumerState<SetupProfileScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  DietaryPreference _preference = DietaryPreference.nonVegetarian;
  final List<String> _selectedAllergies = [];
  final List<String> _commonAllergies = ['Milk', 'Peanuts', 'Gluten', 'Soy', 'Eggs', 'Shellfish', 'Tree Nuts'];

  @override
  void initState() {
    super.initState();
    // Pre-fill name from auth if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authServiceProvider).currentUser;
      if (user?.displayName != null) {
        _nameController.text = user!.displayName!;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Your Chef Profile'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        height: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.secondary,
                  child: Icon(Icons.person_add_rounded, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Basic Info'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Your Name',
                icon: Icons.badge_rounded,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ageController,
                label: 'Age',
                hint: 'How old are you?',
                icon: Icons.cake_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Dietary Preference'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<DietaryPreference>(
                    value: _preference,
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.arrow_drop_down_circle, color: AppColors.primary),
                    items: DietaryPreference.values.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(
                          _formatEnumName(e.name),
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _preference = val!),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Do you have any allergies?'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _commonAllergies.map((allergy) {
                  final isSelected = _selectedAllergies.contains(allergy);
                  return FilterChip(
                    label: Text(allergy),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.accent,
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? AppColors.accent : AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAllergies.add(allergy);
                        } else {
                          _selectedAllergies.remove(allergy);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter your name')),
                    );
                    return;
                  }

                  final user = ref.read(authServiceProvider).currentUser;
                  if (user == null) return;
                  
                  final profile = UserProfileModel(
                    uid: user.uid,
                    fullName: _nameController.text.trim(),
                    email: user.email ?? '', 
                    age: int.tryParse(_ageController.text),
                    allergies: _selectedAllergies,
                    dietaryPreference: _preference,
                  );
                  
                  await ref.read(profileServiceProvider).saveProfile(profile);
                  // Refresh profile provider
                  ref.invalidate(userProfileProvider);

                  if (mounted) context.go('/dashboard');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: AppColors.primary,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('SAVE'),
                    SizedBox(width: 10),
                    Icon(Icons.check_circle_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.secondary),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  String _formatEnumName(String name) {
    return name.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}').trim().capitalize();
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
