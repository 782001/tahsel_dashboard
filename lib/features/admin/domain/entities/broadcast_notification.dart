import 'package:equatable/equatable.dart';

class BroadcastNotification extends Equatable {
  final String id;
  final String title;
  final String body;
  final String targetType;
  final List<String> targetIds;
  final String adminName;
  final DateTime? createdAt;

  const BroadcastNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.targetType,
    this.targetIds = const [],
    required this.adminName,
    this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, title, body, targetType, targetIds, adminName, createdAt];
}
