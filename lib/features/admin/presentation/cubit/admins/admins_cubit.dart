import 'dart:async';
import 'package:tahsel_dashboard/core/base_cubit/safe_cubit.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/dashboard_admin.dart';
import 'package:tahsel_dashboard/features/admin/domain/usecases/admin_management_usecases.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/admins/admins_state.dart';

class AdminsCubit extends SafeCubit<AdminsState> {
  AdminsCubit({
    required GetDashboardAdminsUseCase getAdmins,
    required CreateDashboardAdminUseCase createAdmin,
    required UpdateDashboardAdminUseCase updateAdmin,
    required ToggleAdminStatusUseCase toggleStatus,
    required DeleteDashboardAdminUseCase deleteAdmin,
    required SendAdminPasswordResetEmailUseCase sendPasswordReset,
  })  : _getAdmins = getAdmins,
        _createAdmin = createAdmin,
        _updateAdmin = updateAdmin,
        _toggleStatus = toggleStatus,
        _deleteAdmin = deleteAdmin,
        _sendPasswordReset = sendPasswordReset,
        super(AdminsInitial());

  final GetDashboardAdminsUseCase _getAdmins;
  final CreateDashboardAdminUseCase _createAdmin;
  final UpdateDashboardAdminUseCase _updateAdmin;
  final ToggleAdminStatusUseCase _toggleStatus;
  final DeleteDashboardAdminUseCase _deleteAdmin;
  final SendAdminPasswordResetEmailUseCase _sendPasswordReset;

  StreamSubscription<List<DashboardAdmin>>? _adminsSubscription;
  List<DashboardAdmin> _cachedAdmins = [];

  List<DashboardAdmin> get admins => _cachedAdmins;
  List<DashboardAdmin> get currentAdmins => _cachedAdmins;

  void loadAdmins() {
    emit(AdminsLoading());
    _adminsSubscription?.cancel();
    _adminsSubscription = _getAdmins.stream().listen(
      (adminsList) {
        _cachedAdmins = adminsList;
        emit(AdminsLoaded(adminsList));
      },
      onError: (e) {
        emit(AdminsError(e.toString()));
      },
    );
  }

  Future<bool> createAdmin({
    required String name,
    required String email,
    required String password,
    required String role,
    required List<String> permissions,
  }) async {
    final result = await _createAdmin(CreateDashboardAdminParams(
      name: name,
      email: email,
      password: password,
      role: role,
      permissions: permissions,
    ));

    return result.fold(
      (f) {
        emit(AdminsError(f.message));
        return false;
      },
      (newAdmin) {
        emit(const AdminActionSuccess('تم إنشاء حساب الأدمن بنجاح'));
        return true;
      },
    );
  }

  Future<bool> updateAdmin({
    required String uid,
    required String name,
    required String role,
    required List<String> permissions,
    bool active = true,
  }) async {
    final result = await _updateAdmin(UpdateDashboardAdminParams(
      uid: uid,
      name: name,
      role: role,
      permissions: permissions,
      active: active,
    ));

    return result.fold(
      (f) {
        emit(AdminsError(f.message));
        return false;
      },
      (_) {
        emit(const AdminActionSuccess('تم تحديث بيانات وصلاحيات الأدمن بنجاح'));
        return true;
      },
    );
  }

  Future<bool> toggleAdminStatus({
    required String uid,
    required bool active,
  }) async {
    final result = await _toggleStatus(ToggleAdminStatusParams(
      uid: uid,
      active: active,
    ));

    return result.fold(
      (f) {
        emit(AdminsError(f.message));
        return false;
      },
      (_) {
        emit(AdminActionSuccess(
            active ? 'تم تفعيل حساب الأدمن' : 'تم تعطيل حساب الأدمن'));
        return true;
      },
    );
  }

  Future<bool> toggleStatus(String uid, bool active) =>
      toggleAdminStatus(uid: uid, active: active);

  Future<bool> deleteAdmin(String uid) async {
    final result = await _deleteAdmin(uid);

    return result.fold(
      (f) {
        emit(AdminsError(f.message));
        return false;
      },
      (_) {
        emit(const AdminActionSuccess('تم حذف الأدمن وإلغاء صلاحياته فوراً'));
        return true;
      },
    );
  }

  Future<bool> sendPasswordReset(String email) async {
    final result = await _sendPasswordReset(email);

    return result.fold(
      (f) {
        emit(AdminsError(f.message));
        return false;
      },
      (_) {
        emit(const AdminActionSuccess(
            'تم إرسال رابط إعادة تعيين كلمة المرور إلى البريد الإلكتروني'));
        return true;
      },
    );
  }

  @override
  Future<void> close() {
    _adminsSubscription?.cancel();
    return super.close();
  }
}
