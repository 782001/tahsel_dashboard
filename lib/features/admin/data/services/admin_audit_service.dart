import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tahsel_dashboard/core/constants/admin_constants.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/admin_user.dart';

class AdminAuditService {
  AdminAuditService(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> log({
    required AdminUser admin,
    required String actionType,
    String? targetUserId,
    String? targetUserName,
    Map<String, dynamic>? metadata,
  }) async {
    final ref = _firestore.collection(AdminConstants.auditLogsCollection).doc();
    await ref.set({
      'id': ref.id,
      'timestamp': FieldValue.serverTimestamp(),
      'adminId': admin.uid,
      'adminName': admin.name,
      'actionType': actionType,
      'targetUserId': targetUserId,
      'targetUserName': targetUserName,
      'metadata': metadata ?? {},
    });
  }
}
