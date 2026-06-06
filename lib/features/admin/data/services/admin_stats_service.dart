import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tahsel_dashboard/core/constants/admin_constants.dart';

/// Refreshes aggregated dashboard counters (Spark-compatible client-side).
class AdminStatsService {
  AdminStatsService(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> refresh() async {
    final usersRef = _firestore.collection(AdminConstants.usersCollection);
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final sevenDaysLater = now.add(const Duration(days: 7));

    final results = await Future.wait([
      usersRef.where('accountStatus', isNotEqualTo: 'deleted').count().get(),
      usersRef.where('accountStatus', isEqualTo: 'active').count().get(),
      usersRef.where('accountStatus', isEqualTo: 'suspended').count().get(),
      usersRef.where('subscriptionStatus', isEqualTo: 'expired').count().get(),
      usersRef
          .where('subscriptionStatus', whereIn: ['active', 'expiring_soon'])
          .where('subscriptionEnd', isLessThanOrEqualTo: Timestamp.fromDate(sevenDaysLater))
          .count()
          .get(),
      usersRef
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
          .count()
          .get(),
    ]);

    await _firestore
        .collection(AdminConstants.dashboardStatsCollection)
        .doc(AdminConstants.dashboardStatsDoc)
        .set({
      'totalUsers': results[0].count,
      'activeUsers': results[1].count,
      'suspendedUsers': results[2].count,
      'expiredSubscriptions': results[3].count,
      'expiringSoon': results[4].count,
      'newUsersThisMonth': results[5].count,
      'monthlyRevenue': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
