import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../core/constants/colors.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all the yummy details!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = await ref.read(authServiceProvider).signUp(
        email,
        password,
        name,
      );

      final user = credential.user;
      if (user != null) {
        await ref.read(profileServiceProvider).createOrUpdateUser(
          user.uid,
          name: name,
          email: email,
          provider: 'password',
        );
      }

      if (mounted) context.go('/setup-profile');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signupWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final credential = await ref.read(authServiceProvider).signInWithGoogle();
      
      final user = credential.user;
      if (user != null) {
        await ref.read(profileServiceProvider).createOrUpdateUser(
          user.uid,
          name: user.displayName,
          email: user.email,
          photoUrl: user.photoURL,
          provider: 'google',
        );
      }

      if (mounted) context.go('/setup-profile');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Join the Kitchen!'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        height: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Image.asset('cookandsnaplogo.jpeg', height: 120),
                ),
                const SizedBox(height: 30),
                _buildTextField(
                  controller: _nameController,
                  label: 'Your Name',
                  icon: Icons.person_rounded,
                  hint: 'Chef Awesome',
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_rounded,
                  hint: 'chef@example.com',
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_rounded,
                  hint: '••••••••',
                  isPassword: true,
                ),
                const SizedBox(height: 40),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          ElevatedButton(
                            onPressed: _signup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                            ),
                            child: const Text('Start My Journey!'),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _signupWithGoogle,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                            ),
                            icon: const Icon(Icons.g_mobiledata, size: 30),
                            label: const Text('Sign up with Google'),
                          ),
                        ],
                      ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Already a Chef? Log In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: isPassword && _obscurePassword,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
