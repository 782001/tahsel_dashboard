import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahsel_dashboard/core/base_usecase/base_usecase.dart';
import 'package:tahsel_dashboard/features/admin/domain/usecases/admin_usecases.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/user_detail/user_detail_state.dart';

class UserDetailCubit extends Cubit<UserDetailState> {
  UserDetailCubit({
    required GetUserByIdUseCase getUser,
    required GetUserNotesUseCase getNotes,
    required GetUserSessionsUseCase getSessions,
    required UpdateUserUseCase updateUser,
    required ResetPasswordUseCase resetPassword,
    required ForceLogoutUseCase forceLogout,
    required SubscriptionActionUseCase subscriptionAction,
    required ManageNoteUseCase manageNote,
    required GetAuditLogsUseCase getAuditLogs,
  })  : _getUser = getUser,
        _getNotes = getNotes,
        _getSessions = getSessions,
        _updateUser = updateUser,
        _resetPassword = resetPassword,
        _forceLogout = forceLogout,
        _subscriptionAction = subscriptionAction,
        _manageNote = manageNote,
        _getAuditLogs = getAuditLogs,
        super(UserDetailInitial());

  final GetUserByIdUseCase _getUser;
  final GetUserNotesUseCase _getNotes;
  final GetUserSessionsUseCase _getSessions;
  final UpdateUserUseCase _updateUser;
  final ResetPasswordUseCase _resetPassword;
  final ForceLogoutUseCase _forceLogout;
  final SubscriptionActionUseCase _subscriptionAction;
  final ManageNoteUseCase _manageNote;
  final GetAuditLogsUseCase _getAuditLogs;

  String? _uid;

  Future<void> load(String uid) async {
    _uid = uid;
    emit(UserDetailLoading());
    final userResult = await _getUser(uid);
    await userResult.fold(
      (f) async => emit(UserDetailError(f.message)),
      (user) async {
        final notesResult = await _getNotes(NotesParams(uid: uid));
        final sessionsResult = await _getSessions(uid);
        notesResult.fold(
          (f) => emit(UserDetailError(f.message)),
          (notesPage) {
            sessionsResult.fold(
              (f) => emit(UserDetailError(f.message)),
              (sessions) => emit(UserDetailLoaded(
                user: user,
                notes: notesPage.items,
                sessions: sessions,
                notesHasMore: notesPage.hasMore,
                notesCursor: notesPage.lastCursor,
              )),
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
}
