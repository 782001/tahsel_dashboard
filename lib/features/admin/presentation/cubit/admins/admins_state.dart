import 'package:equatable/equatable.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/dashboard_admin.dart';

abstract class AdminsState extends Equatable {
  const AdminsState();

  @override
  List<Object?> get props => [];
}

class AdminsInitial extends AdminsState {}

class AdminsLoading extends AdminsState {}

class AdminsLoaded extends AdminsState {
  final List<DashboardAdmin> admins;

  const AdminsLoaded(this.admins);

  @override
  List<Object?> get props => [admins];
}

class AdminsError extends AdminsState {
  final String message;

  const AdminsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminActionSuccess extends AdminsState {
  final String message;

  const AdminActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
