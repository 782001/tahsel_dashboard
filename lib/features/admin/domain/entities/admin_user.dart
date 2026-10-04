import 'package:equatable/equatable.dart';
import 'package:tahsel_dashboard/core/constants/admin_permissions.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/dashboard_admin.dart';

class AdminUser extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String role;
  final List<String>? permissions;

  const AdminUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.permissions,
  });

  bool get isPrimarySuperAdmin =>
      email.toLowerCase().trim() == DashboardAdmin.primaryAdminEmail;

  bool get isSuperAdmin =>
      role == AdminPermissions.superAdmin ||
      permissions?.contains('*') == true ||
      isPrimarySuperAdmin;

  bool hasPermission(String permission) =>
      AdminPermissions.has(role, permissions, permission, email: email);

  bool get canWriteUsers => hasPermission(AdminPermissions.usersWrite);
  bool get canReadUsers => hasPermission(AdminPermissions.usersRead);
  bool get canWriteSubscriptions =>
      hasPermission(AdminPermissions.subscriptionsWrite);
  bool get canReadSubscriptions =>
      hasPermission(AdminPermissions.subscriptionsRead);
  bool get canWriteNotifications =>
      hasPermission(AdminPermissions.notificationsWrite);
  bool get canReadNotifications =>
      hasPermission(AdminPermissions.notificationsRead);
  bool get canWriteSettings => hasPermission(AdminPermissions.settingsWrite);
  bool get canReadSettings => hasPermission(AdminPermissions.settingsRead);
  bool get canWriteAudit => hasPermission(AdminPermissions.auditWrite);
  bool get canReadAudit => hasPermission(AdminPermissions.auditRead);
  bool get canManageAdmins => isPrimarySuperAdmin;

  bool get canWrite => canWriteUsers;

  String get roleDisplayName {
    if (isPrimarySuperAdmin) return 'المالك الأساسي';
    switch (role) {
      case AdminPermissions.superAdmin:
        return 'مدير عام';
      case AdminPermissions.admin:
        return 'مدير نظام';
      case AdminPermissions.support:
        return 'دعم فني';
      default:
        return 'مخصص';
    }
  }

  @override
  List<Object?> get props => [uid, email, name, role, permissions];
}

