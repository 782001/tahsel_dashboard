import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahsel_dashboard/core/services/injection_container.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/user_detail/user_detail_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/screens/login/admin_login_screen.dart';
import 'package:tahsel_dashboard/features/admin/presentation/screens/shell/admin_shell_route.dart';
import 'package:tahsel_dashboard/features/admin/presentation/screens/users/user_detail_screen.dart';
import 'package:tahsel_dashboard/features/splash/splash_screen.dart';
import 'package:tahsel_dashboard/features/standard_features/security/presentation/screens/security_warning_screen.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String securityWarning = '/security-warning';
  static const String adminLogin = '/admin-login';
  static const String adminShell = '/admin';
  static const String userDetail = '/admin/user';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case securityWarning:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SecurityWarningScreen(
            isRooted: args?['isRooted'] ?? false,
            isDevMode: args?['isDevMode'] ?? false,
          ),
        );

      case adminLogin:
        return MaterialPageRoute(builder: (_) => const AdminLoginScreen());

      case adminShell:
        return MaterialPageRoute(builder: (_) => const AdminShellRoute());

      case userDetail:
        final uid = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<UserDetailCubit>(),
            child: UserDetailScreen(uid: uid),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: TextWidget('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
