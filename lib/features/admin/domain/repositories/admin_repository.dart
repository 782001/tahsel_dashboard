import 'package:dartz/dartz.dart';
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

enum ReleasePlatform { android, ios, windows }

abstract class AdminRepository {
  Future<Either<Failure, AdminUser>> signIn(String email, String password);
  Future<Either<Failure, void>> signOut();
    Future<Either<Failure, AdminUser>> verifySession();
  Future<Either<Failure, DashboardStats>> getDashboardStats();
  Future<Either<Failure, PaginatedResult<AppUser>>> getUsers({
    int limit,
    String? cursor,
    String? accountStatus,
    String? subscriptionStatus,
  });
  Future<Either<Failure, PaginatedResult<AppUser>>> searchUsers({
    required String query,
    int limit,
    String? cursor,
  });
  Future<Either<Failure, PaginatedResult<AppUser>>> getExpiringUsers({
    required int withinDays,
    int limit,
    String? cursor,
  });
  Future<Either<Failure, AppUser>> getUserById(String uid);
  Future<Either<Failure, PaginatedResult<AuditLog>>> getAuditLogs({
    int limit,
    String? cursor,
    String? targetUserId,
  });
  Future<Either<Failure, PaginatedResult<UserNote>>> getUserNotes({
    required String uid,
    int limit,
    String? cursor,
  });
  Future<Either<Failure, List<UserSession>>> getUserSessions(String uid);
  Future<Either<Failure, AppSettings>> getAppSettings();
  Future<Either<Failure, PaginatedResult<BroadcastNotification>>> getNotifications({
    int limit,
    String? cursor,
  });
  Future<Either<Failure, Map<String, dynamic>>> createUser(Map<String, dynamic> data);
  Future<Either<Failure, void>> updateUser(Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteUser(String uid);
  Future<Either<Failure, void>> disableUser(String uid);
  Future<Either<Failure, void>> suspendUser(String uid);
  Future<Either<Failure, void>> activateUser(String uid);
  Future<Either<Failure, void>> resetPassword(String uid, String newPassword);
  Future<Either<Failure, void>> forceLogout(String uid);
  Future<Either<Failure, void>> renewSubscription(String uid, int days);
  Future<Either<Failure, void>> extendSubscription(String uid, int days);
  Future<Either<Failure, void>> shortenSubscription(String uid, int days);
  Future<Either<Failure, void>> suspendSubscription(String uid);
  Future<Either<Failure, void>> reactivateSubscription(String uid);
  Future<Either<Failure, void>> createNote(String uid, String content);
  Future<Either<Failure, void>> updateNote(String uid, String noteId, String content);
  Future<Either<Failure, void>> deleteNote(String uid, String noteId);
  Future<Either<Failure, void>> sendNotification(Map<String, dynamic> data);
  Future<Either<Failure, void>> updateAppSettings(AppSettings settings);
  Future<Either<Failure, void>> updatePlatformRelease(
    ReleasePlatform platform,
    PlatformRelease release,
  );
  Future<Either<Failure, void>> setupInitialAdmin(String email, String name);
  Future<Either<Failure, void>> checkExpiredAccounts();
}
