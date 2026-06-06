import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/services/injection_container.dart';
import 'package:tahsel_dashboard/core/services/navigator_service.dart';
import 'package:tahsel_dashboard/core/services/security_service.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
import 'package:tahsel_dashboard/core/utils/assets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/auth/auth_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/auth/auth_state.dart';
import 'package:tahsel_dashboard/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));

    _controller.forward();

    _navigateToNext();
  }

  void _navigateToNext() async {
    // 1. Perform security checks (e.g., root detection, developer mode)
    await SecurityService.checkSecurity();

    // 2. Minimum splash duration for branding
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        sl<NavigatorService>().pushNamedAndRemoveUntil(AppRoutes.adminShell);
      } else {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await context.read<AuthCubit>().checkSession();
          if (mounted && context.read<AuthCubit>().state is AuthAuthenticated) {
            sl<NavigatorService>().pushNamedAndRemoveUntil(AppRoutes.adminShell);
            return;
          }
        }
        sl<NavigatorService>().pushNamedAndRemoveUntil(AppRoutes.adminLogin);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: AppColors.isDark
            ? Brightness.light
            : Brightness.dark, // Dark icons
        statusBarBrightness: AppColors.isDark
            ? Brightness.dark
            : Brightness.light, // iOS dark text
      ),
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: Stack(
          children: [
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Image.asset(
                          Assets.imagesAppLogo,
                          width: 180.h,
                          height: 180.h,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
