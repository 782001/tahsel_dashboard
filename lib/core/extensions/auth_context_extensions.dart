import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahsel_dashboard/core/constants/admin_permissions.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/admin_user.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/auth/auth_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/auth/auth_state.dart';

extension AuthContextExtensions on BuildContext {
  /// Reads the current authenticated admin without listening for changes.
  AdminUser? get currentAdmin {
    try {
      final state = read<AuthCubit>().state;
      if (state is AuthAuthenticated) {
        return state.admin;
      }
    } catch (_) {}
    return null;
  }

  /// Watches the current authenticated admin and rebuilds when it changes.
  AdminUser? get watchAdmin {
    try {
      final state = watch<AuthCubit>().state;
      if (state is AuthAuthenticated) {
        return state.admin;
      }
    } catch (_) {}
    return null;
  }

  /// Checks if the current admin has the given permission (non-reactive).
  bool hasPermission(String permission) {
    return currentAdmin?.hasPermission(permission) ?? false;
  }

  /// Checks if the current admin has the given permission (reactive rebuild on change).
  bool watchHasPermission(String permission) {
    return watchAdmin?.hasPermission(permission) ?? false;
  }

  // Convenient reactive getters
  bool get canWriteUsers => watchHasPermission(AdminPermissions.usersWrite);
  bool get canReadUsers => watchHasPermission(AdminPermissions.usersRead);
  bool get canWriteSubscriptions =>
      watchHasPermission(AdminPermissions.subscriptionsWrite);
  bool get canReadSubscriptions =>
      watchHasPermission(AdminPermissions.subscriptionsRead);
  bool get canWriteNotifications =>
      watchHasPermission(AdminPermissions.notificationsWrite);
  bool get canReadNotifications =>
      watchHasPermission(AdminPermissions.notificationsRead);
  bool get canWriteSettings =>
      watchHasPermission(AdminPermissions.settingsWrite);
  bool get canReadSettings => watchHasPermission(AdminPermissions.settingsRead);
  bool get canWriteAudit => watchHasPermission(AdminPermissions.auditWrite);
  bool get canReadAudit => watchHasPermission(AdminPermissions.auditRead);
  bool get canManageAdmins => watchAdmin?.canManageAdmins ?? false;
  bool get isSuperAdmin => watchAdmin?.isSuperAdmin ?? false;
}
