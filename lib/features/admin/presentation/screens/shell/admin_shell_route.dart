import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahsel_dashboard/core/services/injection_container.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/audit/audit_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/dashboard/dashboard_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/notifications/notifications_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/settings/settings_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/user_detail/user_detail_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/users/users_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/screens/shell/admin_shell.dart';

class AdminShellRoute extends StatelessWidget {
  const AdminShellRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<DashboardCubit>()),
        BlocProvider(create: (_) => sl<UsersCubit>()),
        BlocProvider(create: (_) => sl<ExpirationCubit>()),
        BlocProvider(create: (_) => sl<AuditCubit>()),
        BlocProvider(create: (_) => sl<NotificationsCubit>()),
        BlocProvider(create: (_) => sl<SettingsCubit>()),
        BlocProvider(create: (_) => sl<UserDetailCubit>()),
      ],
      child: const AdminShell(),
    );
  }
}
