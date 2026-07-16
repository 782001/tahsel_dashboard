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
  });

  factory AppUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final statsMap = data['stats'] as Map<String, dynamic>? ?? {};
    return AppUserModel(
      uid: doc.id,
      fullName: data['fullName'] ?? '',
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
      userType: data['userType']??'cafe',
      platformType: data['platformType']??'mobile', 
      projectName: data['projectName'] ?? '',
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
