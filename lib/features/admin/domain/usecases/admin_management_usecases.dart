import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tahsel_dashboard/core/base_usecase/base_usecase.dart';
import 'package:tahsel_dashboard/core/error/failures.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/dashboard_admin.dart';
import 'package:tahsel_dashboard/features/admin/domain/repositories/admin_repository.dart';

class GetDashboardAdminsUseCase
    extends BaseUseCase<List<DashboardAdmin>, NoParams> {
  final AdminRepository _repo;
  GetDashboardAdminsUseCase(this._repo);

  @override
  Future<Either<Failure, List<DashboardAdmin>>> call(NoParams params) =>
      _repo.getAdmins();

  Stream<List<DashboardAdmin>> stream() => _repo.getAdminsStream();
}

class CreateDashboardAdminParams extends Equatable {
  final String name;
  final String email;
  final String password;
  final String role;
  final List<String> permissions;

  const CreateDashboardAdminParams({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.permissions,
  });

  @override
  List<Object?> get props => [name, email, password, role, permissions];
}

class CreateDashboardAdminUseCase
    extends BaseUseCase<DashboardAdmin, CreateDashboardAdminParams> {
  final AdminRepository _repo;
  CreateDashboardAdminUseCase(this._repo);

  @override
  Future<Either<Failure, DashboardAdmin>> call(
          CreateDashboardAdminParams params) =>
      _repo.createDashboardAdmin(
        name: params.name,
        email: params.email,
        password: params.password,
        role: params.role,
        permissions: params.permissions,
      );
}

class UpdateDashboardAdminParams extends Equatable {
  final String uid;
  final String name;
  final String role;
  final List<String> permissions;
  final bool active;

  const UpdateDashboardAdminParams({
    required this.uid,
    required this.name,
    required this.role,
    required this.permissions,
    required this.active,
  });

  @override
  List<Object?> get props => [uid, name, role, permissions, active];
}

class UpdateDashboardAdminUseCase
    extends BaseUseCase<void, UpdateDashboardAdminParams> {
  final AdminRepository _repo;
  UpdateDashboardAdminUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(UpdateDashboardAdminParams params) =>
      _repo.updateDashboardAdmin(
        uid: params.uid,
        name: params.name,
        role: params.role,
        permissions: params.permissions,
        active: params.active,
      );
}

class ToggleAdminStatusParams extends Equatable {
  final String uid;
  final bool active;

  const ToggleAdminStatusParams({
    required this.uid,
    required this.active,
  });

  @override
  List<Object?> get props => [uid, active];
}

class ToggleAdminStatusUseCase
    extends BaseUseCase<void, ToggleAdminStatusParams> {
  final AdminRepository _repo;
  ToggleAdminStatusUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(ToggleAdminStatusParams params) =>
      _repo.toggleAdminStatus(
        uid: params.uid,
        active: params.active,
      );
}

class DeleteDashboardAdminUseCase extends BaseUseCase<void, String> {
  final AdminRepository _repo;
  DeleteDashboardAdminUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(String uid) =>
      _repo.deleteDashboardAdmin(uid);
}

class SendAdminPasswordResetEmailUseCase extends BaseUseCase<void, String> {
  final AdminRepository _repo;
  SendAdminPasswordResetEmailUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(String email) =>
      _repo.sendAdminPasswordResetEmail(email);
}
