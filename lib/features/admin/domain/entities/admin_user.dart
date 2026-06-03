import 'package:equatable/equatable.dart';

class AdminUser extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String role;

  const AdminUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });

  bool get isSuperAdmin => role == 'super_admin';
  bool get canWrite => role == 'super_admin' || role == 'admin';

  @override
  List<Object?> get props => [uid, email, name, role];
}
