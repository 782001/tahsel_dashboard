import 'package:tahsel_dashboard/core/base_cubit/safe_cubit.dart';
import 'package:tahsel_dashboard/features/admin/domain/usecases/admin_usecases.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/user_detail/user_detail_state.dart';

class UserDetailCubit extends SafeCubit<UserDetailState> {
  UserDetailCubit({
    required GetUserByIdUseCase getUser,
    required GetUserNotesUseCase getNotes,
    required GetUserSessionsUseCase getSessions,
    required GetTenantEmployeesUseCase getEmployees,
    required UpdateUserUseCase updateUser,
    required DeleteUserUseCase deleteUser,
    required DisableUserUseCase disableUser,
    required SuspendUserUseCase suspendUser,
    required ActivateUserUseCase activateUser,
    required ResetPasswordUseCase resetPassword,
    required ForceLogoutUseCase forceLogout,
    required SubscriptionActionUseCase subscriptionAction,
    required ManageNoteUseCase manageNote,
  })  : _getUser = getUser,
        _getNotes = getNotes,
        _getSessions = getSessions,
        _getEmployees = getEmployees,
        _updateUser = updateUser,
        _deleteUser = deleteUser,
        _disableUser = disableUser,
        _suspendUser = suspendUser,
        _activateUser = activateUser,
        _resetPassword = resetPassword,
        _forceLogout = forceLogout,
        _subscriptionAction = subscriptionAction,
        _manageNote = manageNote,
        super(UserDetailInitial());

  final GetUserByIdUseCase _getUser;
  final GetUserNotesUseCase _getNotes;
  final GetUserSessionsUseCase _getSessions;
  final GetTenantEmployeesUseCase _getEmployees;
  final UpdateUserUseCase _updateUser;
  final DeleteUserUseCase _deleteUser;
  final DisableUserUseCase _disableUser;
  final SuspendUserUseCase _suspendUser;
  final ActivateUserUseCase _activateUser;
  final ResetPasswordUseCase _resetPassword;
  final ForceLogoutUseCase _forceLogout;
  final SubscriptionActionUseCase _subscriptionAction;
  final ManageNoteUseCase _manageNote;

  String? _uid;

  Future<void> load(String uid) async {
    _uid = uid;
    if (isClosed) return;
    emit(UserDetailLoading());
    final userResult = await _getUser(uid);
    if (isClosed) return;
    await userResult.fold(
      (f) async {
        if (!isClosed) emit(UserDetailError(f.message));
      },
      (user) async {
        if (isClosed) return;
        final notesResult = await _getNotes(NotesParams(uid: uid));
        if (isClosed) return;
        final sessionsResult = await _getSessions(uid);
        if (isClosed) return;
        final employeesResult = await _getEmployees(uid);
        if (isClosed) return;
        final employees = employeesResult.getOrElse(() => []);

        notesResult.fold(
          (f) {
            if (!isClosed) emit(UserDetailError(f.message));
          },
          (notesPage) {
            if (isClosed) return;
            sessionsResult.fold(
              (f) {
                if (!isClosed) emit(UserDetailError(f.message));
              },
              (sessions) {
                if (!isClosed) {
                  emit(UserDetailLoaded(
                    user: user,
                    notes: notesPage.items,
                    sessions: sessions,
                    employees: employees,
                    notesHasMore: notesPage.hasMore,
                    notesCursor: notesPage.lastCursor,
                  ));
                }
              },
            );
          },
        );
      },
    );
  }

  Future<bool> updateUser(UpdateUserParams params) async {
    emit(UserDetailActionLoading());
    final result = await _updateUser(params);
    return result.fold((f) {
      emit(UserDetailError(f.message));
      return false;
    }, (_) async {
      await load(_uid!);
      return true;
    });
  }

  Future<bool> resetPassword(String newPassword) async {
    final result = await _resetPassword(
      ResetPasswordParams(uid: _uid!, newPassword: newPassword),
    );
    return result.fold((f) {
      emit(UserDetailError(f.message));
      return false;
    }, (_) => true);
  }

  Future<bool> forceLogout() async {
    final result = await _forceLogout(_uid!);
    return result.fold((f) {
      emit(UserDetailError(f.message));
      return false;
    }, (_) async {
      await load(_uid!);
      return true;
    });
  }

  Future<bool> subscriptionAction(SubscriptionParams params) async {
    emit(UserDetailActionLoading());
    final result = await _subscriptionAction(params);
    return result.fold((f) {
      emit(UserDetailError(f.message));
      return false;
    }, (_) async {
      await load(_uid!);
      return true;
    });
  }

  Future<bool> addNote(String content) async {
    final result = await _manageNote(NoteActionParams(
      uid: _uid!,
      action: NoteAction.create,
      content: content,
    ));
    return result.fold((f) => false, (_) async {
      await load(_uid!);
      return true;
    });
  }

  Future<bool> deleteNote(String noteId) async {
    final result = await _manageNote(NoteActionParams(
      uid: _uid!,
      action: NoteAction.delete,
      noteId: noteId,
    ));
    return result.fold((f) => false, (_) async {
      await load(_uid!);
      return true;
    });
  }

  Future<bool> editNote(String noteId, String content) async {
    final result = await _manageNote(NoteActionParams(
      uid: _uid!,
      action: NoteAction.update,
      noteId: noteId,
      content: content,
    ));
    return result.fold((f) => false, (_) async {
      await load(_uid!);
      return true;
    });
  }

  Future<bool> suspendUser() async {
    emit(UserDetailActionLoading());
    final result = await _suspendUser(_uid!);
    return result.fold((f) {
      emit(UserDetailError(f.message));
      return false;
    }, (_) async {
      await load(_uid!);
      return true;
    });
  }

  Future<bool> disableUser() async {
    emit(UserDetailActionLoading());
    final result = await _disableUser(_uid!);
    return result.fold((f) {
      emit(UserDetailError(f.message));
      return false;
    }, (_) async {
      await load(_uid!);
      return true;
    });
  }

  Future<bool> activateUser() async {
    emit(UserDetailActionLoading());
    final result = await _activateUser(_uid!);
    return result.fold((f) {
      emit(UserDetailError(f.message));
      return false;
    }, (_) async {
      await load(_uid!);
      return true;
    });
  }

  Future<bool> deleteUser() async {
    emit(UserDetailActionLoading());
    final result = await _deleteUser(_uid!);
    return result.fold((f) {
      emit(UserDetailError(f.message));
      return false;
    }, (_) => true);
  }
}
