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

  bool get isActive => accountStatus == 'active';

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
