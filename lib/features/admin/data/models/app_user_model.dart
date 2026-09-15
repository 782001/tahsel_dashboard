import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.uid,
    required super.fullName,
    required super.email,
    required super.phoneNumber,
    required super.accountStatus,
    required super.subscriptionStatus,
    super.createdAt,
    super.lastLogin,
    super.lastActive,
    super.subscriptionStart,
    super.subscriptionEnd,
    super.devicePlatform,
    super.stats,
    super.subscriptionSuspended,
    super.userType, 
    super.platformType,
    super.projectName,
    super.isVip,
    super.role,
    super.ownerUid,
    super.crn,
    super.vat,
    super.taxRate,
    super.address,
  });

  factory AppUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final statsMap = data['stats'] as Map<String, dynamic>? ?? {};
    final ownerUid = data['ownerUid'] as String?;
    final role = data['role'] as String? ?? (ownerUid != null ? 'employee' : 'owner');
    final fullName = (data['fullName'] as String?)?.isNotEmpty == true
        ? data['fullName'] as String
        : (data['name'] as String? ?? '');

    return AppUserModel(
      uid: doc.id,
      fullName: fullName,
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      accountStatus: data['accountStatus'] ?? 'active',
      subscriptionStatus: data['subscriptionStatus'] ?? 'expired',
      createdAt: _toDate(data['createdAt']),
      lastLogin: _toDate(data['lastLogin']),
      lastActive: _toDate(data['lastActive']),
      subscriptionStart: _toDate(data['subscriptionStart']),
      subscriptionEnd: _toDate(data['subscriptionEnd']),
      devicePlatform: data['devicePlatform'],
      subscriptionSuspended: data['subscriptionSuspended'] ?? false,
      userType: data['userType'] ?? 'cafe',
      platformType: data['platformType'] ?? 'mobile', 
      projectName: data['projectName'] ?? '',
      isVip: data['isVip'] ?? false,
      role: role,
      ownerUid: ownerUid,
      crn: data['crn'] as String?,
      vat: data['vat'] as String?,
      taxRate: (data['taxRate'] as num?)?.toDouble(),
      address: data['address'] as String?,
      stats: UserStats(
        customers: statsMap['customers'] ?? 0,
        debts: statsMap['debts'] ?? 0,
        employees: statsMap['employees'] ?? 0,
        transactions: statsMap['transactions'] ?? 0,
        expenses: statsMap['expenses'] ?? 0,
      ),
    );
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
