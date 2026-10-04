import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:tahsel_dashboard/features/admin/domain/entities/tenant_employee.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/dashboard_admin.dart';
import 'package:tahsel_dashboard/features/admin/domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._remote);

  final AdminRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<TenantEmployee>>> getTenantEmployees(
          String ownerUid) =>
      _guard(() => _remote.getTenantEmployees(ownerUid));

  @override
  Future<Either<Failure, void>> updateTenantEmployeePermissions({
    required String ownerUid,
    required String employeeId,
    required String rolePreset,
    required List<String> permissions,
  }) =>
      _guard(() => _remote.updateTenantEmployeePermissions(
            ownerUid: ownerUid,
            employeeId: employeeId,
            rolePreset: rolePreset,
            permissions: permissions,
          ));

  @override
  Future<Either<Failure, TenantEmployee>> createAppEmployee({
    required String ownerUid,
    required String name,
    required String email,
    required String password,
    required String rolePreset,
    required List<String> permissions,
  }) =>
      _guard(() => _remote.createAppEmployee(
            ownerUid: ownerUid,
            name: name,
            email: email,
            password: password,
            rolePreset: rolePreset,
            permissions: permissions,
          ));

  @override
  Future<Either<Failure, void>> updateAppEmployee({
    required String ownerUid,
    required String employeeId,
    required String name,
    required String rolePreset,
    required List<String> permissions,
  }) =>
      _guard(() => _remote.updateAppEmployee(
            ownerUid: ownerUid,
            employeeId: employeeId,
            name: name,
            rolePreset: rolePreset,
            permissions: permissions,
          ));

  @override
  Future<Either<Failure, void>> toggleEmployeeStatus({
    required String ownerUid,
    required String employeeId,
    required String newStatus,
  }) =>
      _guard(() => _remote.toggleEmployeeStatus(
            ownerUid: ownerUid,
            employeeId: employeeId,
            newStatus: newStatus,
          ));

  @override
  Future<Either<Failure, void>> deleteAppEmployee({
    required String ownerUid,
    required String employeeId,
  }) =>
      _guard(() => _remote.deleteAppEmployee(
            ownerUid: ownerUid,
            employeeId: employeeId,
          ));

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(FirebaseErrorHandler.getMessage(e)));
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
        permissions: (data['permissions'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
      );

  @override
  Future<Either<Failure, AdminUser>> signIn(String email, String password) =>
      _guard(() async {
        await _remote.signIn(email, password);
        final Map<String, dynamic> session;
        try {
          session = await _remote.verifySession();
        } catch (_) {
          await _remote.signOut();
          rethrow;
        }
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
      _guard(() => _remote.createUser(data));

  @override
  Future<Either<Failure, void>> updateUser(Map<String, dynamic> data) =>
      _guard(() => _remote.updateUser(data));

  @override
  Future<Either<Failure, void>> deleteUser(String uid) =>
      _guard(() => _remote.deleteUser(uid));

  @override
  Future<Either<Failure, void>> disableUser(String uid) =>
      _guard(() => _remote.disableUser(uid));

  @override
  Future<Either<Failure, void>> suspendUser(String uid) =>
      _guard(() => _remote.suspendUser(uid));

  @override
  Future<Either<Failure, void>> activateUser(String uid) =>
      _guard(() => _remote.activateUser(uid));

  @override
  Future<Either<Failure, void>> resetPassword(String uid, String newPassword) =>
      _guard(() => _remote.sendPasswordResetEmail(uid));

  @override
  Future<Either<Failure, void>> forceLogout(String uid) =>
      _guard(() => _remote.forceLogout(uid));

  @override
  Future<Either<Failure, void>> renewSubscription(String uid, int days) =>
      _guard(() => _remote.renewSubscription(uid, days));

  @override
  Future<Either<Failure, void>> extendSubscription(String uid, int days) =>
      _guard(() => _remote.extendSubscription(uid, days));

  @override
  Future<Either<Failure, void>> shortenSubscription(String uid, int days) =>
      _guard(() => _remote.shortenSubscription(uid, days));

  @override
  Future<Either<Failure, void>> suspendSubscription(String uid) =>
      _guard(() => _remote.suspendSubscription(uid));

  @override
  Future<Either<Failure, void>> reactivateSubscription(String uid) =>
      _guard(() => _remote.reactivateSubscription(uid));

  @override
  Future<Either<Failure, void>> createNote(String uid, String content) =>
      _guard(() => _remote.createNote(uid, content));

  @override
  Future<Either<Failure, void>> updateNote(
          String uid, String noteId, String content) =>
      _guard(() => _remote.updateNote(uid, noteId, content));

  @override
  Future<Either<Failure, void>> deleteNote(String uid, String noteId) =>
      _guard(() => _remote.deleteNote(uid, noteId));

  @override
  Future<Either<Failure, void>> sendNotification(Map<String, dynamic> data) =>
      _guard(() => _remote.sendNotification(data));

  @override
  Future<Either<Failure, void>> updateAppSettings(AppSettings settings) =>
      _guard(() => _remote.updateAppSettings(settings));

  @override
  Future<Either<Failure, void>> updatePlatformRelease(
    ReleasePlatform platform,
    PlatformRelease release,
  ) =>
      _guard(() => _remote.updatePlatformRelease(platform, release));

  @override
  Future<Either<Failure, void>> setupInitialAdmin(String email, String name) =>
      _guard(() => _remote.setupInitialAdmin(email, name));

  @override
  Future<Either<Failure, void>> checkExpiredAccounts() =>
      _guard(_remote.checkExpiredAccounts);

  @override
  Stream<List<DashboardAdmin>> getAdminsStream() => _remote.getAdminsStream();

  @override
  Future<Either<Failure, List<DashboardAdmin>>> getAdmins() =>
      _guard(_remote.getAdmins);

  @override
  Future<Either<Failure, DashboardAdmin>> createDashboardAdmin({
    required String name,
    required String email,
    required String password,
    required String role,
    required List<String> permissions,
  }) =>
      _guard(() => _remote.createDashboardAdmin(
            name: name,
            email: email,
            password: password,
            role: role,
            permissions: permissions,
          ));

  @override
  Future<Either<Failure, void>> updateDashboardAdmin({
    required String uid,
    required String name,
    required String role,
    required List<String> permissions,
    required bool active,
  }) =>
      _guard(() => _remote.updateDashboardAdmin(
            uid: uid,
            name: name,
            role: role,
            permissions: permissions,
            active: active,
          ));

  @override
  Future<Either<Failure, void>> toggleAdminStatus({
    required String uid,
    required bool active,
  }) =>
      _guard(() => _remote.toggleAdminStatus(
            uid: uid,
            active: active,
          ));

  @override
  Future<Either<Failure, void>> deleteDashboardAdmin(String uid) =>
      _guard(() => _remote.deleteDashboardAdmin(uid));

  @override
  Future<Either<Failure, void>> sendAdminPasswordResetEmail(String email) =>
      _guard(() => _remote.sendAdminPasswordResetEmail(email));
}
