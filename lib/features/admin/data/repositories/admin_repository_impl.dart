import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:tahsel_dashboard/core/error/failures.dart';
import 'package:tahsel_dashboard/core/error/firebase_error_handler.dart';
import 'package:tahsel_dashboard/core/models/paginated_result.dart';
import 'package:tahsel_dashboard/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/admin_user.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/app_settings.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/app_user.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/audit_log.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/broadcast_notification.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/dashboard_stats.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/user_note.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/user_session.dart';
import 'package:tahsel_dashboard/features/admin/domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._remote);

  final AdminRemoteDataSource _remote;

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(FirebaseErrorHandler.getMessage(e)));
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(FirebaseErrorHandler.getMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  AdminUser _mapAdmin(Map<String, dynamic> data) => AdminUser(
        uid: data['uid'] ?? '',
        email: data['email'] ?? '',
        name: data['name'] ?? '',
        role: data['role'] ?? 'support',
      );

  @override
  Future<Either<Failure, AdminUser>> signIn(String email, String password) =>
      _guard(() async {
        await _remote.signIn(email, password);
        final session = await _remote.verifySession();
        return _mapAdmin(session);
      });

  @override
  Future<Either<Failure, void>> signOut() => _guard(_remote.signOut);

  @override
  Future<Either<Failure, AdminUser>> verifySession() => _guard(() async {
        final session = await _remote.verifySession();
        return _mapAdmin(session);
      });

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() =>
      _guard(_remote.getDashboardStats);

  @override
  Future<Either<Failure, PaginatedResult<AppUser>>> getUsers({
    int limit = 15,
    String? cursor,
    String? accountStatus,
    String? subscriptionStatus,
  }) =>
      _guard(() => _remote.getUsers(
            limit: limit,
            cursor: cursor,
            accountStatus: accountStatus,
            subscriptionStatus: subscriptionStatus,
          ));

  @override
  Future<Either<Failure, PaginatedResult<AppUser>>> searchUsers({
    required String query,
    int limit = 15,
    String? cursor,
  }) =>
      _guard(() => _remote.searchUsers(query: query, limit: limit, cursor: cursor));

  @override
  Future<Either<Failure, PaginatedResult<AppUser>>> getExpiringUsers({
    required int withinDays,
    int limit = 15,
    String? cursor,
  }) =>
      _guard(() => _remote.getExpiringUsers(
            withinDays: withinDays,
            limit: limit,
            cursor: cursor,
          ));

  @override
  Future<Either<Failure, AppUser>> getUserById(String uid) =>
      _guard(() => _remote.getUserById(uid));

  @override
  Future<Either<Failure, PaginatedResult<AuditLog>>> getAuditLogs({
    int limit = 15,
    String? cursor,
    String? targetUserId,
  }) =>
      _guard(() => _remote.getAuditLogs(
            limit: limit,
            cursor: cursor,
            targetUserId: targetUserId,
          ));

  @override
  Future<Either<Failure, PaginatedResult<UserNote>>> getUserNotes({
    required String uid,
    int limit = 15,
    String? cursor,
  }) =>
      _guard(() => _remote.getUserNotes(uid: uid, limit: limit, cursor: cursor));

  @override
  Future<Either<Failure, List<UserSession>>> getUserSessions(String uid) =>
      _guard(() => _remote.getUserSessions(uid));

  @override
  Future<Either<Failure, AppSettings>> getAppSettings() =>
      _guard(_remote.getAppSettings);

  @override
  Future<Either<Failure, PaginatedResult<BroadcastNotification>>> getNotifications({
    int limit = 15,
    String? cursor,
  }) =>
      _guard(() => _remote.getNotifications(limit: limit, cursor: cursor));

  @override
  Future<Either<Failure, Map<String, dynamic>>> createUser(
          Map<String, dynamic> data) =>
      _guard(() => _remote.callFunction('adminCreateUser', data: data));

  @override
  Future<Either<Failure, void>> updateUser(Map<String, dynamic> data) => _guard(
        () => _remote.callFunction('adminUpdateUser', data: data),
      );

  @override
  Future<Either<Failure, void>> deleteUser(String uid) => _guard(
        () => _remote.callFunction('adminDeleteUser', data: {'uid': uid}),
      );

  @override
  Future<Either<Failure, void>> suspendUser(String uid) => _guard(
        () => _remote.callFunction('adminSuspendUser', data: {'uid': uid}),
      );

  @override
  Future<Either<Failure, void>> activateUser(String uid) => _guard(
        () => _remote.callFunction('adminActivateUser', data: {'uid': uid}),
      );

  @override
  Future<Either<Failure, void>> resetPassword(String uid, String newPassword) =>
      _guard(() => _remote.callFunction('adminResetPassword', data: {
            'uid': uid,
            'newPassword': newPassword,
          }));

  @override
  Future<Either<Failure, void>> forceLogout(String uid) => _guard(
        () => _remote.callFunction('adminForceLogout', data: {'uid': uid}),
      );

  @override
  Future<Either<Failure, void>> renewSubscription(String uid, int days) =>
      _guard(() => _remote.callFunction('adminRenewSubscription', data: {
            'uid': uid,
            'days': days,
          }));

  @override
  Future<Either<Failure, void>> extendSubscription(String uid, int days) =>
      _guard(() => _remote.callFunction('adminExtendSubscription', data: {
            'uid': uid,
            'days': days,
          }));

  @override
  Future<Either<Failure, void>> shortenSubscription(String uid, int days) =>
      _guard(() => _remote.callFunction('adminShortenSubscription', data: {
            'uid': uid,
            'days': days,
          }));

  @override
  Future<Either<Failure, void>> suspendSubscription(String uid) => _guard(
        () => _remote.callFunction('adminSuspendSubscription', data: {'uid': uid}),
      );

  @override
  Future<Either<Failure, void>> reactivateSubscription(String uid) => _guard(
        () =>
            _remote.callFunction('adminReactivateSubscription', data: {'uid': uid}),
      );

  @override
  Future<Either<Failure, void>> createNote(String uid, String content) => _guard(
        () => _remote.callFunction('adminCreateNote', data: {
          'uid': uid,
          'content': content,
        }),
      );

  @override
  Future<Either<Failure, void>> updateNote(
          String uid, String noteId, String content) =>
      _guard(() => _remote.callFunction('adminUpdateNote', data: {
            'uid': uid,
            'noteId': noteId,
            'content': content,
          }));

  @override
  Future<Either<Failure, void>> deleteNote(String uid, String noteId) => _guard(
        () => _remote.callFunction('adminDeleteNote', data: {
          'uid': uid,
          'noteId': noteId,
        }),
      );

  @override
  Future<Either<Failure, void>> sendNotification(Map<String, dynamic> data) =>
      _guard(() => _remote.callFunction('adminSendNotification', data: data));

  @override
  Future<Either<Failure, void>> updateAppSettings(AppSettings settings) =>
      _guard(() => _remote.callFunction('adminUpdateAppSettings', data: {
            'minSupportedVersion': settings.minSupportedVersion,
            'latestVersion': settings.latestVersion,
            'forceUpdate': settings.forceUpdate,
          }));

  @override
  Future<Either<Failure, void>> setupInitialAdmin(String email, String name) =>
      _guard(() => _remote.callFunction('adminSetupInitialAdmin', data: {
            'email': email,
            'name': name,
          }));
}
