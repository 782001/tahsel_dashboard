import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tahsel_dashboard/core/base_cubit/safe_cubit.dart';
import 'package:tahsel_dashboard/core/base_usecase/base_usecase.dart';
import 'package:tahsel_dashboard/core/constants/admin_constants.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/admin_user.dart';
import 'package:tahsel_dashboard/features/admin/domain/usecases/admin_usecases.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/auth/auth_state.dart';
import 'package:tahsel_dashboard/shared/widgets/toast/custom_toast.dart';

class AuthCubit extends SafeCubit<AuthState> {
  AuthCubit({
    required SignInAdminUseCase signIn,
    required VerifyAdminSessionUseCase verifySession,
    required SignOutAdminUseCase signOut,
    required SetupInitialAdminUseCase setupAdmin,
  })  : _signIn = signIn,
        _verifySession = verifySession,
        _signOut = signOut,
        _setupAdmin = setupAdmin,
        super(AuthInitial());

  final SignInAdminUseCase _signIn;
  final VerifyAdminSessionUseCase _verifySession;
  final SignOutAdminUseCase _signOut;
  final SetupInitialAdminUseCase _setupAdmin;

  StreamSubscription<DocumentSnapshot>? _adminSessionSubscription;

  void startAdminSessionWatcher(String uid) {
    _adminSessionSubscription?.cancel();
    _adminSessionSubscription = FirebaseFirestore.instance
        .collection(AdminConstants.adminsCollection)
        .doc(uid)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) {
        showfailureToast('تم إلغاء صلاحيات هذا الحساب، تم تسجيل الخروج تلقائياً');
        await logout();
        return;
      }
      final data = snapshot.data();
      if (data == null || data['active'] == false) {
        showfailureToast('تم تعطيل حسابك من قِبل المدير العام، تم تسجيل الخروج تلقائياً');
        await logout();
        return;
      }

      final updatedAdmin = AdminUser(
        uid: snapshot.id,
        email: data['email'] as String? ?? '',
        name: data['name'] as String? ?? '',
        role: data['role'] as String? ?? 'support',
        permissions: (data['permissions'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
      );

      if (state is! AuthAuthenticated ||
          (state as AuthAuthenticated).admin != updatedAdmin) {
        emit(AuthAuthenticated(updatedAdmin));
      }
    }, onError: (_) async {
      await logout();
    });
  }

  void stopAdminSessionWatcher() {
    _adminSessionSubscription?.cancel();
    _adminSessionSubscription = null;
  }

  Future<void> checkSession() async {
    emit(AuthLoading());
    final result = await _verifySession(const NoParams());
    result.fold(
      (_) => emit(AuthUnauthenticated()),
      (admin) {
        startAdminSessionWatcher(admin.uid);
        emit(AuthAuthenticated(admin));
      },
    );
  }

  /// Validates the current Firebase Auth user against both the Auth provider
  /// and the Firestore `accountStatus` field.
  Future<void> validateAccountStatus() async {
    emit(AuthLoading());
    try {
      await FirebaseAuth.instance.currentUser?.reload();

      final result = await _verifySession(const NoParams());
      result.fold(
        (_) async {
          stopAdminSessionWatcher();
          await _signOut(const NoParams());
          emit(AuthUnauthenticated());
        },
        (admin) {
          startAdminSessionWatcher(admin.uid);
          emit(AuthAuthenticated(admin));
        },
      );
    } catch (_) {
      stopAdminSessionWatcher();
      await _signOut(const NoParams());
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final result =
        await _signIn(SignInParams(email: email, password: password));
    result.fold(
      (f) => emit(AuthError(f.message)),
      (admin) {
        startAdminSessionWatcher(admin.uid);
        emit(AuthAuthenticated(admin));
      },
    );
  }

  Future<void> setupAdmin(String email, String name) async {
    emit(AuthLoading());
    final result =
        await _setupAdmin(SetupAdminParams(email: email, name: name));
    result.fold(
      (f) => emit(AuthError(f.message)),
      (_) => checkSession(),
    );
  }

  Future<void> logout() async {
    stopAdminSessionWatcher();
    await _signOut(const NoParams());
    emit(AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    stopAdminSessionWatcher();
    return super.close();
  }
}
