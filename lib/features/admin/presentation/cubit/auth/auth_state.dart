import 'package:equatable/equatable.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/admin_user.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AdminUser admin;
  const AuthAuthenticated(this.admin);
  @override
  List<Object?> get props => [admin];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
