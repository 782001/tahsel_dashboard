import 'package:firebase_auth/firebase_auth.dart';
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

  /// Validates the current Firebase Auth user against both the Auth provider
  /// and the Firestore `accountStatus` field.
  ///
  /// This is the mandatory security gate called on every app startup before
  /// routing an already-authenticated user to the shell. It ensures that:
  ///   1. The Firebase Auth token is still valid (catches server-side disabling).
  ///   2. The Firestore `accountStatus` is still `'active'` (the hardened
  ///      security rules will deny the read if it is not, giving a
  ///      `permission-denied` error that is treated as a revocation signal).
  ///
  /// On any failure the user is signed out and [AuthUnauthenticated] is emitted.
  Future<void> validateAccountStatus() async {
    emit(AuthLoading());
    try {
      // Step 1: Reload the Firebase Auth token. If the account has been
      // disabled at the Firebase Auth level this throws a FirebaseAuthException
      // with code 'user-disabled' or 'user-not-found'.
      await FirebaseAuth.instance.currentUser?.reload();

      // Step 2: Verify the admin session and accountStatus via Firestore.
      // The hardened security rules will return permission-denied if
      // accountStatus != 'active', so any Firestore error is treated as
      // an access-revoked signal.
      final result = await _verifySession(const NoParams());
      result.fold(
        (_) async {
          await _signOut(const NoParams());
          emit(AuthUnauthenticated());
        },
        (admin) => emit(AuthAuthenticated(admin)),
      );
    } catch (_) {
      // Any exception (user-disabled, permission-denied, network, etc.)
      // is treated as a revocation signal — sign out immediately.
      await _signOut(const NoParams());
      emit(AuthUnauthenticated());
    }
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
