import 'package:dartz/dartz.dart';
import 'package:tahsel_dashboard/core/base_usecase/base_usecase.dart';
import 'package:tahsel_dashboard/core/error/failures.dart';
import 'package:tahsel_dashboard/core/models/paginated_result.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/admin_user.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/app_settings.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/app_user.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/audit_log.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/broadcast_notification.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/dashboard_stats.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/user_note.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/user_session.dart';
import 'package:tahsel_dashboard/features/admin/domain/repositories/admin_repository.dart';

class SignInAdminUseCase extends BaseUseCase<AdminUser, SignInParams> {
  SignInAdminUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, AdminUser>> call(SignInParams params) =>
      _repo.signIn(params.email, params.password);
}

class SignInParams {
  final String email;
  final String password;
  SignInParams({required this.email, required this.password});
}

class VerifyAdminSessionUseCase extends BaseUseCase<AdminUser, NoParams> {
  VerifyAdminSessionUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, AdminUser>> call(NoParams params) =>
      _repo.verifySession();
}

class SignOutAdminUseCase extends BaseUseCase<void, NoParams> {
  SignOutAdminUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, void>> call(NoParams params) => _repo.signOut();
}

class GetDashboardStatsUseCase extends BaseUseCase<DashboardStats, NoParams> {
  GetDashboardStatsUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, DashboardStats>> call(NoParams params) =>
      _repo.getDashboardStats();
}

class GetUsersUseCase extends BaseUseCase<PaginatedResult<AppUser>, UsersQueryParams> {
  GetUsersUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, PaginatedResult<AppUser>>> call(UsersQueryParams params) =>
      _repo.getUsers(
        limit: params.limit,
        cursor: params.cursor,
        accountStatus: params.accountStatus,
        subscriptionStatus: params.subscriptionStatus,
      );
}

class UsersQueryParams {
  final int limit;
  final String? cursor;
  final String? accountStatus;
  final String? subscriptionStatus;
  UsersQueryParams({
    this.limit = 15,
    this.cursor,
    this.accountStatus,
    this.subscriptionStatus,
  });
}

class SearchUsersUseCase extends BaseUseCase<PaginatedResult<AppUser>, SearchParams> {
  SearchUsersUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, PaginatedResult<AppUser>>> call(SearchParams params) =>
      _repo.searchUsers(query: params.query, limit: params.limit, cursor: params.cursor);
}

class SearchParams {
  final String query;
  final int limit;
  final String? cursor;
  SearchParams({required this.query, this.limit = 15, this.cursor});
}

class GetExpiringUsersUseCase
    extends BaseUseCase<PaginatedResult<AppUser>, ExpiringParams> {
  GetExpiringUsersUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, PaginatedResult<AppUser>>> call(ExpiringParams params) =>
      _repo.getExpiringUsers(
        withinDays: params.withinDays,
        limit: params.limit,
        cursor: params.cursor,
      );
}

class ExpiringParams {
  final int withinDays;
  final int limit;
  final String? cursor;
  ExpiringParams({required this.withinDays, this.limit = 15, this.cursor});
}

class GetUserByIdUseCase extends BaseUseCase<AppUser, String> {
  GetUserByIdUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, AppUser>> call(String uid) => _repo.getUserById(uid);
}

class GetAuditLogsUseCase extends BaseUseCase<PaginatedResult<AuditLog>, AuditQueryParams> {
  GetAuditLogsUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, PaginatedResult<AuditLog>>> call(AuditQueryParams params) =>
      _repo.getAuditLogs(
        limit: params.limit,
        cursor: params.cursor,
        targetUserId: params.targetUserId,
      );
}

class AuditQueryParams {
  final int limit;
  final String? cursor;
  final String? targetUserId;
  AuditQueryParams({this.limit = 15, this.cursor, this.targetUserId});
}

class CreateUserUseCase extends BaseUseCase<Map<String, dynamic>, CreateUserParams> {
  CreateUserUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, Map<String, dynamic>>> call(CreateUserParams params) =>
      _repo.createUser(params.toMap());
}

class CreateUserParams {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;
  final String? projectName;
  final int subscriptionDays;
  final String userType;
  final String platformType;
  final bool isVip;

  CreateUserParams({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
    this.projectName,
    this.subscriptionDays = 30,
    this.userType = 'cafe',
    this.platformType = 'mobile',
    this.isVip = false,
  });

  Map<String, dynamic> toMap() => {
        'email': email,
        'password': password,
        'fullName': fullName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (projectName != null) 'projectName': projectName,
        'subscriptionDays': subscriptionDays,
        'userType': userType,
        'platformType': platformType,
        'isVip': isVip,
      };
}

class UpdateUserUseCase extends BaseUseCase<void, UpdateUserParams> {
  UpdateUserUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, void>> call(UpdateUserParams params) =>
      _repo.updateUser(params.toMap());
}

class UpdateUserParams {
  final String uid;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? userType;
  final String? platformType;
  final bool? isVip;

  UpdateUserParams({
    required this.uid,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.userType,
    this.platformType,
    this.isVip,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        if (fullName != null) 'fullName': fullName,
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (userType != null) 'userType': userType,
        if (platformType != null) 'platformType': platformType,
        if (isVip != null) 'isVip': isVip,
      };
}

class DeleteUserUseCase extends BaseUseCase<void, String> {
  DeleteUserUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, void>> call(String uid) => _repo.deleteUser(uid);
}

class DisableUserUseCase extends BaseUseCase<void, String> {
  DisableUserUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, void>> call(String uid) => _repo.disableUser(uid);
}

class SuspendUserUseCase extends BaseUseCase<void, String> {
  SuspendUserUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, void>> call(String uid) => _repo.suspendUser(uid);
}

class ActivateUserUseCase extends BaseUseCase<void, String> {
  ActivateUserUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, void>> call(String uid) => _repo.activateUser(uid);
}

class ResetPasswordUseCase extends BaseUseCase<void, ResetPasswordParams> {
  ResetPasswordUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) =>
      _repo.resetPassword(params.uid, params.newPassword);
}

class ResetPasswordParams {
  final String uid;
  final String newPassword;
  ResetPasswordParams({required this.uid, required this.newPassword});
}

class ForceLogoutUseCase extends BaseUseCase<void, String> {
  ForceLogoutUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, void>> call(String uid) => _repo.forceLogout(uid);
}

class SubscriptionActionUseCase extends BaseUseCase<void, SubscriptionParams> {
  SubscriptionActionUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, void>> call(SubscriptionParams params) {
    switch (params.action) {
      case SubscriptionAction.renew:
        return _repo.renewSubscription(params.uid, params.days);
      case SubscriptionAction.extend:
        return _repo.extendSubscription(params.uid, params.days);
      case SubscriptionAction.shorten:
        return _repo.shortenSubscription(params.uid, params.days);
      case SubscriptionAction.suspend:
        return _repo.suspendSubscription(params.uid);
      case SubscriptionAction.reactivate:
        return _repo.reactivateSubscription(params.uid);
    }
  }
}

enum SubscriptionAction { renew, extend, shorten, suspend, reactivate }

class SubscriptionParams {
  final String uid;
  final int days;
  final SubscriptionAction action;
  SubscriptionParams({
    required this.uid,
    required this.action,
    this.days = 30,
  });
}

class GetUserNotesUseCase extends BaseUseCase<PaginatedResult<UserNote>, NotesParams> {
  GetUserNotesUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, PaginatedResult<UserNote>>> call(NotesParams params) =>
      _repo.getUserNotes(uid: params.uid, limit: params.limit, cursor: params.cursor);
}

class NotesParams {
  final String uid;
  final int limit;
  final String? cursor;
  NotesParams({required this.uid, this.limit = 15, this.cursor});
}

class ManageNoteUseCase extends BaseUseCase<void, NoteActionParams> {
  ManageNoteUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, void>> call(NoteActionParams params) {
    switch (params.action) {
      case NoteAction.create:
        return _repo.createNote(params.uid, params.content!);
      case NoteAction.update:
        return _repo.updateNote(params.uid, params.noteId!, params.content!);
      case NoteAction.delete:
        return _repo.deleteNote(params.uid, params.noteId!);
    }
  }
}

enum NoteAction { create, update, delete }

class NoteActionParams {
  final String uid;
  final NoteAction action;
  final String? noteId;
  final String? content;
  NoteActionParams({
    required this.uid,
    required this.action,
    this.noteId,
    this.content,
  });
}

class GetUserSessionsUseCase extends BaseUseCase<List<UserSession>, String> {
  GetUserSessionsUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, List<UserSession>>> call(String uid) =>
      _repo.getUserSessions(uid);
}

class GetAppSettingsUseCase extends BaseUseCase<AppSettings, NoParams> {
  GetAppSettingsUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, AppSettings>> call(NoParams params) =>
      _repo.getAppSettings();
}

class UpdateAppSettingsUseCase extends BaseUseCase<void, AppSettings> {
  UpdateAppSettingsUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, void>> call(AppSettings params) =>
      _repo.updateAppSettings(params);
}

class UpdatePlatformReleaseUseCase
    extends BaseUseCase<void, UpdatePlatformReleaseParams> {
  UpdatePlatformReleaseUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, void>> call(UpdatePlatformReleaseParams params) =>
      _repo.updatePlatformRelease(params.platform, params.release);
}

class UpdatePlatformReleaseParams {
  final ReleasePlatform platform;
  final PlatformRelease release;
  UpdatePlatformReleaseParams({required this.platform, required this.release});
}

class SendNotificationUseCase extends BaseUseCase<void, NotificationParams> {
  SendNotificationUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, void>> call(NotificationParams params) =>
      _repo.sendNotification(params.toMap());
}

class NotificationParams {
  final String title;
  final String body;
  final String targetType;
  final List<String>? targetIds;

  NotificationParams({
    required this.title,
    required this.body,
    required this.targetType,
    this.targetIds,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'targetType': targetType,
        if (targetIds != null) 'targetIds': targetIds,
      };
}

class GetNotificationsUseCase
    extends BaseUseCase<PaginatedResult<BroadcastNotification>, PaginationParams> {
  GetNotificationsUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, PaginatedResult<BroadcastNotification>>> call(
          PaginationParams params) =>
      _repo.getNotifications(limit: params.limit, cursor: params.cursor);
}

class SetupInitialAdminUseCase extends BaseUseCase<void, SetupAdminParams> {
  SetupInitialAdminUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, void>> call(SetupAdminParams params) =>
      _repo.setupInitialAdmin(params.email, params.name);
}

class SetupAdminParams {
  final String email;
  final String name;
  SetupAdminParams({required this.email, required this.name});
}

class CheckExpiredAccountsUseCase extends BaseUseCase<void, NoParams> {
  CheckExpiredAccountsUseCase(this._repo);
  final AdminRepository _repo;
  @override
  Future<Either<Failure, void>> call(NoParams params) =>
      _repo.checkExpiredAccounts();
}

