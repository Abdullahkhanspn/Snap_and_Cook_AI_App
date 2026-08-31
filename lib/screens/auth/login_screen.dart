import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../core/constants/colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = await ref.read(authServiceProvider).signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      final user = credential.user;
      if (user != null) {
        await ref.read(profileServiceProvider).createOrUpdateUser(
          user.uid,
          name: user.displayName,
          email: user.email,
          photoUrl: user.photoURL,
          provider: 'password',
        );
      }

      if (mounted) context.go('/dashboard');
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

  Future<void> _loginWithGoogle() async {
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

      if (mounted) context.go('/dashboard');
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

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email first')),
      );
      return;
    }

    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!'), backgroundColor: AppColors.primary),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 60.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'cookandsnaplogo.jpeg',
                    height: 150,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Log in to start cooking yummy food!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              shadowColor: AppColors.primary.withOpacity(0.4),
                              elevation: 8,
                            ),
                            child: const Text('Let\'s Cook!'),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _loginWithGoogle,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                            ),
                            icon: const Icon(Icons.g_mobiledata, size: 30),
                            label: const Text('Continue with Google'),
                          ),
                        ],
                      ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.push('/signup'),
                  child: RichText(
                    text: TextSpan(
                      text: 'New here? ',
                      style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Quicksand'),
                      children: [
                        const TextSpan(
                          text: 'Join the kitchen!',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
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
