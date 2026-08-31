import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/profile/setup_profile_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/result/ai_result_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/setup-profile', builder: (context, state) => const SetupProfileScreen()),
    GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
    GoRoute(path: '/result', builder: (context, state) => const AiResultScreen()),
  ],
);

class SnapAndCookApp extends ConsumerWidget {
  const SnapAndCookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Snap & Cook',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
