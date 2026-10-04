import 'package:equatable/equatable.dart';

class DashboardAdmin extends Equatable {
  static const String primaryAdminEmail = 'admin@tahsel.com';

  final String uid;
  final String email;
  final String name;
  final String role;
  final List<String> permissions;
  final bool active;
  final DateTime? createdAt;
  final DateTime? lastUpdatedAt;

  const DashboardAdmin({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.permissions = const [],
    this.active = true,
    this.createdAt,
    this.lastUpdatedAt,
  });

  bool get isPrimarySuperAdmin => email.toLowerCase().trim() == primaryAdminEmail;

  bool get isSuperAdmin => role == 'super_admin' || permissions.contains('*');

  String get roleDisplayArabic {
    switch (role) {
      case 'super_admin':
        return 'مدير عام';
      case 'admin':
        return 'مدير نظام';
      case 'support':
        return 'دعم فني';
      default:
        return 'مخصص';
    }
  }

  DashboardAdmin copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    List<String>? permissions,
    bool? active,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
  }) {
    return DashboardAdmin(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        name,
        role,
        permissions,
        active,
        createdAt,
        lastUpdatedAt,
      ];
}
