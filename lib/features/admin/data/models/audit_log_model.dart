import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/audit_log.dart';

class AuditLogModel extends AuditLog {
  const AuditLogModel({
    required super.id,
    super.timestamp,
    required super.adminId,
    required super.adminName,
    required super.actionType,
    super.targetUserId,
    super.targetUserName,
    super.metadata,
  });

  factory AuditLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    DateTime? timestamp;
    final ts = data['timestamp'];
    if (ts is Timestamp) timestamp = ts.toDate();
    return AuditLogModel(
      id: doc.id,
      timestamp: timestamp,
      adminId: data['adminId'] ?? '',
      adminName: data['adminName'] ?? '',
      actionType: data['actionType'] ?? '',
      targetUserId: data['targetUserId'],
      targetUserName: data['targetUserName'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }
}
