import 'package:equatable/equatable.dart';

class AuditLog extends Equatable {
  final String id;
  final DateTime? timestamp;
  final String adminId;
  final String adminName;
  final String actionType;
  final String? targetUserId;
  final String? targetUserName;
  final Map<String, dynamic> metadata;

  const AuditLog({
    required this.id,
    this.timestamp,
    required this.adminId,
    required this.adminName,
    required this.actionType,
    this.targetUserId,
    this.targetUserName,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        timestamp,
        adminId,
        adminName,
        actionType,
        targetUserId,
        targetUserName,
        metadata,
      ];
}
