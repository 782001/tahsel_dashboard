import 'package:equatable/equatable.dart';
import 'package:tahsel_dashboard/core/constants/admin_permissions.dart';

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

  bool get isSuperAdmin => role == 'super_admin';
  bool get canWrite => role == 'super_admin' || role == 'admin';

  bool hasPermission(String permission) =>
      AdminPermissions.has(role, permissions, permission);

  @override
  List<Object?> get props => [uid, email, name, role, permissions];
}
