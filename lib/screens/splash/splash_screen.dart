import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../core/constants/colors.dart';
import '../../models/user_profile_model.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _animationFinished = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    
    _controller.forward().then((_) {
      if (mounted) {
        setState(() => _animationFinished = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkAndNavigate() {
    if (_navigated || !_animationFinished) return;

    final authState = ref.read(authStateProvider);
    
    if (authState is AsyncData) {
      final user = authState.value;
      if (user == null) {
        _navigated = true;
        context.go('/login');
      } else {
        final profileAsync = ref.read(userProfileProvider);
        if (profileAsync is AsyncData<UserProfileModel?>) {
          _navigated = true;
          if (profileAsync.value == null) {
            context.go('/setup-profile');
          } else {
            context.go('/dashboard');
          }
        }
      }
    } else if (authState is AsyncError) {
      _navigated = true;
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authStateProvider);
    ref.watch(userProfileProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndNavigate());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'cookandsnaplogo.jpeg',
                    width: 280,
                    height: 280,
                  ),
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
