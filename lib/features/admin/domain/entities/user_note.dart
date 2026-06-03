import 'package:equatable/equatable.dart';

class UserNote extends Equatable {
  final String id;
  final String content;
  final String adminId;
  final String adminName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserNote({
    required this.id,
    required this.content,
    required this.adminId,
    required this.adminName,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, content, adminId, adminName, createdAt, updatedAt];
}
