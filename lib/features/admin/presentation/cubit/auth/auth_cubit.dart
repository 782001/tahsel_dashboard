import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahsel_dashboard/core/base_usecase/base_usecase.dart';
import 'package:tahsel_dashboard/features/admin/domain/usecases/admin_usecases.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
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

  Future<void> checkSession() async {
    emit(AuthLoading());
    final result = await _verifySession(const NoParams());
    result.fold(
      (_) => emit(AuthUnauthenticated()),
      (admin) => emit(AuthAuthenticated(admin)),
    );
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final result = await _signIn(SignInParams(email: email, password: password));
    result.fold(
      (f) => emit(AuthError(f.message)),
      (admin) => emit(AuthAuthenticated(admin)),
    );
  }

  Future<void> setupAdmin(String email, String name) async {
    emit(AuthLoading());
    final result = await _setupAdmin(SetupAdminParams(email: email, name: name));
    result.fold(
      (f) => emit(AuthError(f.message)),
      (_) => checkSession(),
    );
  }

  Future<void> logout() async {
    await _signOut(const NoParams());
    emit(AuthUnauthenticated());
  }
}
