import 'package:tahsel_dashboard/core/base_cubit/safe_cubit.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/tenant_employee.dart';
import 'package:tahsel_dashboard/features/admin/domain/usecases/admin_usecases.dart';
import 'team_management_state.dart';

class TeamManagementCubit extends SafeCubit<TeamManagementState> {
  final GetTenantEmployeesUseCase _getEmployees;
  final CreateAppEmployeeUseCase _createEmployee;
  final UpdateAppEmployeeUseCase _updateEmployee;
  final ToggleEmployeeStatusUseCase _toggleStatus;
  final DeleteAppEmployeeUseCase _deleteEmployee;

  TeamManagementCubit({
    required GetTenantEmployeesUseCase getEmployees,
    required CreateAppEmployeeUseCase createEmployee,
    required UpdateAppEmployeeUseCase updateEmployee,
    required ToggleEmployeeStatusUseCase toggleStatus,
    required DeleteAppEmployeeUseCase deleteEmployee,
  })  : _getEmployees = getEmployees,
        _createEmployee = createEmployee,
        _updateEmployee = updateEmployee,
        _toggleStatus = toggleStatus,
        _deleteEmployee = deleteEmployee,
        super(TeamManagementInitial());

  List<TenantEmployee> _employees = [];
  List<TenantEmployee> get employees => List.unmodifiable(_employees);

  Future<void> loadEmployees(String ownerUid) async {
    emit(TeamManagementLoading());
    final result = await _getEmployees(ownerUid);
    result.fold(
      (failure) => emit(TeamManagementFailure(failure.message)),
      (list) {
        _employees = List.from(list);
        emit(TeamManagementLoaded(_employees));
      },
    );
  }

  Future<bool> addEmployee({
    required String ownerUid,
    required String name,
    required String email,
    required String password,
    required String rolePreset,
    required List<String> permissions,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanName.isEmpty) {
      emit(const TeamManagementFailure('اسم الموظف مطلوب'));
      return false;
    }
    if (cleanEmail.isEmpty) {
      emit(const TeamManagementFailure('البريد الإلكتروني مطلوب'));
      return false;
    }
    if (cleanPassword.length < 6) {
      emit(const TeamManagementFailure('كلمة المرور يجب أن لا تقل عن 6 أحرف'));
      return false;
    }
    if (permissions.isEmpty) {
      emit(const TeamManagementFailure('يرجى تحديد صلاحية واحدة على الأقل'));
      return false;
    }

    emit(TeamManagementLoading());
    final result = await _createEmployee(
      CreateAppEmployeeParams(
        ownerUid: ownerUid,
        name: cleanName,
        email: cleanEmail,
        password: cleanPassword,
        rolePreset: rolePreset,
        permissions: permissions,
      ),
    );

    return result.fold(
      (failure) {
        emit(TeamManagementFailure(failure.message));
        emit(TeamManagementLoaded(_employees));
        return false;
      },
      (newEmp) {
        _employees.insert(0, newEmp);
        emit(const TeamManagementActionSuccess('تم إنشاء حساب الموظف بنجاح'));
        emit(TeamManagementLoaded(_employees));
        return true;
      },
    );
  }

  Future<bool> updateEmployee({
    required String ownerUid,
    required String employeeId,
    required String name,
    required String rolePreset,
    required List<String> permissions,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      emit(const TeamManagementFailure('اسم الموظف مطلوب'));
      return false;
    }
    if (permissions.isEmpty) {
      emit(const TeamManagementFailure('يرجى تحديد صلاحية واحدة على الأقل'));
      return false;
    }

    emit(TeamManagementLoading());
    final result = await _updateEmployee(
      UpdateAppEmployeeParams(
        ownerUid: ownerUid,
        employeeId: employeeId,
        name: cleanName,
        rolePreset: rolePreset,
        permissions: permissions,
      ),
    );

    return result.fold(
      (failure) {
        emit(TeamManagementFailure(failure.message));
        emit(TeamManagementLoaded(_employees));
        return false;
      },
      (_) {
        final index = _employees.indexWhere((e) => e.id == employeeId);
        if (index != -1) {
          _employees[index] = _employees[index].copyWith(
            name: cleanName,
            rolePreset: rolePreset,
            permissions: permissions,
          );
        }
        emit(const TeamManagementActionSuccess('تم تحديث بيانات وصلاحيات الموظف'));
        emit(TeamManagementLoaded(_employees));
        return true;
      },
    );
  }

  Future<void> toggleStatus({
    required String ownerUid,
    required String employeeId,
    required String currentStatus,
  }) async {
    final newStatus = currentStatus == 'active' ? 'disabled' : 'active';
    final result = await _toggleStatus(
      ToggleEmployeeStatusParams(
        ownerUid: ownerUid,
        employeeId: employeeId,
        newStatus: newStatus,
      ),
    );

    result.fold(
      (failure) {
        emit(TeamManagementFailure(failure.message));
        emit(TeamManagementLoaded(_employees));
      },
      (_) {
        final index = _employees.indexWhere((e) => e.id == employeeId);
        if (index != -1) {
          _employees[index] = _employees[index].copyWith(accountStatus: newStatus);
        }
        final msg = newStatus == 'active' ? 'تم تفعيل حساب الموظف' : 'تم تعطيل حساب الموظف';
        emit(TeamManagementActionSuccess(msg));
        emit(TeamManagementLoaded(_employees));
      },
    );
  }

  Future<bool> deleteEmployee({
    required String ownerUid,
    required String employeeId,
  }) async {
    emit(TeamManagementLoading());
    final result = await _deleteEmployee(
      DeleteAppEmployeeParams(
        ownerUid: ownerUid,
        employeeId: employeeId,
      ),
    );

    return result.fold(
      (failure) {
        emit(TeamManagementFailure(failure.message));
        emit(TeamManagementLoaded(_employees));
        return false;
      },
      (_) {
        _employees.removeWhere((e) => e.id == employeeId);
        emit(const TeamManagementActionSuccess('تم حذف حساب الموظف بنجاح'));
        emit(TeamManagementLoaded(_employees));
        return true;
      },
    );
  }
}
