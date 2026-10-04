import 'package:equatable/equatable.dart';

class TenantEmployee extends Equatable {
  final String id;
  final String name;
  final String email;
  final String rolePreset;
  final String accountStatus;
  final List<String> permissions;
  final DateTime? createdAt;

  const TenantEmployee({
    required this.id,
    required this.name,
    required this.email,
    required this.rolePreset,
    required this.accountStatus,
    this.permissions = const [],
    this.createdAt,
  });

  String get authUid => id;
  bool get isActive => accountStatus == 'active';

  TenantEmployee copyWith({
    String? id,
    String? name,
    String? email,
    String? rolePreset,
    String? accountStatus,
    List<String>? permissions,
    DateTime? createdAt,
  }) =>
      TenantEmployee(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        rolePreset: rolePreset ?? this.rolePreset,
        accountStatus: accountStatus ?? this.accountStatus,
        permissions: permissions ?? this.permissions,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        rolePreset,
        accountStatus,
        permissions,
        createdAt,
      ];
}
