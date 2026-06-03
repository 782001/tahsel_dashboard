import 'package:equatable/equatable.dart';

class UserSession extends Equatable {
  final String id;
  final String platform;
  final DateTime? lastActive;
  final bool active;

  const UserSession({
    required this.id,
    required this.platform,
    this.lastActive,
    this.active = true,
  });

  @override
  List<Object?> get props => [id, platform, lastActive, active];
}
