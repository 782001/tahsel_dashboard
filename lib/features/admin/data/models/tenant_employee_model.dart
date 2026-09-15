import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/tenant_employee.dart';

class TenantEmployeeModel extends TenantEmployee {
  const TenantEmployeeModel({
    required super.id,
    required super.name,
    required super.email,
    required super.rolePreset,
    required super.accountStatus,
    super.permissions,
    super.createdAt,
  });

  factory TenantEmployeeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawPerms = data['permissions'];
    final List<String> perms = rawPerms is List
        ? rawPerms.map((e) => e.toString()).toList()
        : [];

    return TenantEmployeeModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      rolePreset: data['rolePreset'] as String? ?? 'custom',
      accountStatus: data['accountStatus'] as String? ?? 'active',
      permissions: perms,
      createdAt: _toDate(data['createdAt']),
    );
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
