import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/dashboard_admin.dart';

class DashboardAdminModel extends DashboardAdmin {
  const DashboardAdminModel({
    required super.uid,
    required super.email,
    required super.name,
    required super.role,
    super.permissions,
    super.active,
    super.createdAt,
    super.lastUpdatedAt,
  });

  factory DashboardAdminModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawPerms = data['permissions'];
    final List<String> perms = rawPerms is List
        ? rawPerms.map((e) => e.toString()).toList()
        : [];

    return DashboardAdminModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      role: data['role'] as String? ?? 'support',
      permissions: perms,
      active: data['active'] as bool? ?? true,
      createdAt: _toDate(data['createdAt']),
      lastUpdatedAt: _toDate(data['lastUpdatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email.trim().toLowerCase(),
      'name': name.trim(),
      'role': role,
      'permissions': permissions,
      'active': active,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      if (lastUpdatedAt != null) 'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt!),
    };
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
