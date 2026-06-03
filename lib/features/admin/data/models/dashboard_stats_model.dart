import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    super.totalUsers,
    super.activeUsers,
    super.suspendedUsers,
    super.expiredSubscriptions,
    super.expiringSoon,
    super.newUsersThisMonth,
    super.monthlyRevenue,
  });

  factory DashboardStatsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return DashboardStatsModel(
      totalUsers: data['totalUsers'] ?? 0,
      activeUsers: data['activeUsers'] ?? 0,
      suspendedUsers: data['suspendedUsers'] ?? 0,
      expiredSubscriptions: data['expiredSubscriptions'] ?? 0,
      expiringSoon: data['expiringSoon'] ?? 0,
      newUsersThisMonth: data['newUsersThisMonth'] ?? 0,
      monthlyRevenue: (data['monthlyRevenue'] ?? 0).toDouble(),
    );
  }
}
