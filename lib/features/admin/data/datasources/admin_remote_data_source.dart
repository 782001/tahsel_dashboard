import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tahsel_dashboard/core/constants/admin_constants.dart';
import 'package:tahsel_dashboard/core/models/paginated_result.dart';
import 'package:tahsel_dashboard/core/services/cloud_functions_service.dart';
import 'package:tahsel_dashboard/features/admin/data/models/app_user_model.dart';
import 'package:tahsel_dashboard/features/admin/data/models/audit_log_model.dart';
import 'package:tahsel_dashboard/features/admin/data/models/dashboard_stats_model.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/app_settings.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/app_user.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/audit_log.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/broadcast_notification.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/dashboard_stats.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/user_note.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/user_session.dart';

abstract class AdminRemoteDataSource {
  Future<Map<String, dynamic>> verifySession();
  Future<UserCredential> signIn(String email, String password);
  Future<void> signOut();
  Future<DashboardStats> getDashboardStats();
  Future<PaginatedResult<AppUser>> getUsers({
    int limit,
    String? cursor,
    String? accountStatus,
    String? subscriptionStatus,
  });
  Future<PaginatedResult<AppUser>> searchUsers({
    required String query,
    int limit,
    String? cursor,
  });
  Future<PaginatedResult<AppUser>> getExpiringUsers({
    required int withinDays,
    int limit,
    String? cursor,
  });
  Future<AppUser> getUserById(String uid);
  Future<PaginatedResult<AuditLog>> getAuditLogs({
    int limit,
    String? cursor,
    String? targetUserId,
  });
  Future<PaginatedResult<UserNote>> getUserNotes({
    required String uid,
    int limit,
    String? cursor,
  });
  Future<List<UserSession>> getUserSessions(String uid);
  Future<AppSettings> getAppSettings();
  Future<PaginatedResult<BroadcastNotification>> getNotifications({
    int limit,
    String? cursor,
  });
  Future<Map<String, dynamic>> callFunction(
    String name, {
    Map<String, dynamic>? data,
  });
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  AdminRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required CloudFunctionsService functions,
  })  : _firestore = firestore,
        _auth = auth,
        _functions = functions;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final CloudFunctionsService _functions;

  @override
  Future<Map<String, dynamic>> verifySession() async {
    await _functions.ensureAuthToken();
    return _functions.call('adminVerifySession');
  }

  @override
  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<DashboardStats> getDashboardStats() async {
    final doc = await _firestore
        .collection(AdminConstants.dashboardStatsCollection)
        .doc(AdminConstants.dashboardStatsDoc)
        .get();
    if (!doc.exists) return const DashboardStatsModel();
    return DashboardStatsModel.fromFirestore(doc);
  }

  Query<Map<String, dynamic>> _usersQuery({
    String? accountStatus,
    String? subscriptionStatus,
  }) {
    Query<Map<String, dynamic>> query =
        _firestore.collection(AdminConstants.usersCollection);
    if (accountStatus != null) {
      query = query.where('accountStatus', isEqualTo: accountStatus);
    }
    if (subscriptionStatus != null) {
      query = query.where('subscriptionStatus', isEqualTo: subscriptionStatus);
    }
    return query.orderBy('createdAt', descending: true);
  }

  @override
  Future<PaginatedResult<AppUser>> getUsers({
    int limit = AdminConstants.defaultPageSize,
    String? cursor,
    String? accountStatus,
    String? subscriptionStatus,
  }) async {
    Query<Map<String, dynamic>> query = _usersQuery(
      accountStatus: accountStatus,
      subscriptionStatus: subscriptionStatus,
    );
    if (cursor != null) {
      final cursorDoc = await _firestore
          .collection(AdminConstants.usersCollection)
          .doc(cursor)
          .get();
      if (cursorDoc.exists) {
        query = query.startAfterDocument(cursorDoc);
      }
    }
    final snap = await query.limit(limit + 1).get();
    final docs = snap.docs;
    final hasMore = docs.length > limit;
    final items = docs.take(limit).map(AppUserModel.fromFirestore).toList();
    return PaginatedResult(
      items: items,
      hasMore: hasMore,
      lastCursor: items.isNotEmpty ? items.last.uid : null,
    );
  }

  @override
  Future<PaginatedResult<AppUser>> searchUsers({
    required String query,
    int limit = AdminConstants.defaultPageSize,
    String? cursor,
  }) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return getUsers(limit: limit, cursor: cursor);
    }

    Query<Map<String, dynamic>> q = _firestore
        .collection(AdminConstants.usersCollection)
        .where('searchKeywords', arrayContains: normalized)
        .orderBy('createdAt', descending: true);

    if (cursor != null) {
      final cursorDoc = await _firestore
          .collection(AdminConstants.usersCollection)
          .doc(cursor)
          .get();
      if (cursorDoc.exists) q = q.startAfterDocument(cursorDoc);
    }

    final snap = await q.limit(limit + 1).get();
    final docs = snap.docs;
    final hasMore = docs.length > limit;
    final items = docs.take(limit).map(AppUserModel.fromFirestore).toList();
    return PaginatedResult(
      items: items,
      hasMore: hasMore,
      lastCursor: items.isNotEmpty ? items.last.uid : null,
    );
  }

  @override
  Future<PaginatedResult<AppUser>> getExpiringUsers({
    required int withinDays,
    int limit = AdminConstants.defaultPageSize,
    String? cursor,
  }) async {
    final endDate = DateTime.now().add(Duration(days: withinDays));
    Query<Map<String, dynamic>> query = _firestore
        .collection(AdminConstants.usersCollection)
        .where('accountStatus', isEqualTo: 'active')
        .where('subscriptionEnd', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .where('subscriptionEnd', isGreaterThan: Timestamp.now())
        .orderBy('subscriptionEnd');

    if (cursor != null) {
      final cursorDoc = await _firestore
          .collection(AdminConstants.usersCollection)
          .doc(cursor)
          .get();
      if (cursorDoc.exists) query = query.startAfterDocument(cursorDoc);
    }

    final snap = await query.limit(limit + 1).get();
    final docs = snap.docs;
    final hasMore = docs.length > limit;
    final items = docs.take(limit).map(AppUserModel.fromFirestore).toList();
    return PaginatedResult(
      items: items,
      hasMore: hasMore,
      lastCursor: items.isNotEmpty ? items.last.uid : null,
    );
  }

  @override
  Future<AppUser> getUserById(String uid) async {
    final doc = await _firestore
        .collection(AdminConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) throw Exception('User not found');
    return AppUserModel.fromFirestore(doc);
  }

  @override
  Future<PaginatedResult<AuditLog>> getAuditLogs({
    int limit = AdminConstants.defaultPageSize,
    String? cursor,
    String? targetUserId,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(AdminConstants.auditLogsCollection)
        .orderBy('timestamp', descending: true);

    if (targetUserId != null) {
      query = query.where('targetUserId', isEqualTo: targetUserId);
    }

    if (cursor != null) {
      final cursorDoc = await _firestore
          .collection(AdminConstants.auditLogsCollection)
          .doc(cursor)
          .get();
      if (cursorDoc.exists) query = query.startAfterDocument(cursorDoc);
    }

    final snap = await query.limit(limit + 1).get();
    final docs = snap.docs;
    final hasMore = docs.length > limit;
    final items = docs.take(limit).map(AuditLogModel.fromFirestore).toList();
    return PaginatedResult(
      items: items,
      hasMore: hasMore,
      lastCursor: items.isNotEmpty ? items.last.id : null,
    );
  }

  @override
  Future<PaginatedResult<UserNote>> getUserNotes({
    required String uid,
    int limit = AdminConstants.defaultPageSize,
    String? cursor,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(AdminConstants.usersCollection)
        .doc(uid)
        .collection(AdminConstants.notesSubcollection)
        .orderBy('createdAt', descending: true);

    if (cursor != null) {
      final cursorDoc = await _firestore
          .collection(AdminConstants.usersCollection)
          .doc(uid)
          .collection(AdminConstants.notesSubcollection)
          .doc(cursor)
          .get();
      if (cursorDoc.exists) query = query.startAfterDocument(cursorDoc);
    }

    final snap = await query.limit(limit + 1).get();
    final docs = snap.docs;
    final hasMore = docs.length > limit;
    final items = docs.take(limit).map((doc) {
      final data = doc.data();
      DateTime? createdAt;
      DateTime? updatedAt;
      if (data['createdAt'] is Timestamp) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      }
      if (data['updatedAt'] is Timestamp) {
        updatedAt = (data['updatedAt'] as Timestamp).toDate();
      }
      return UserNote(
        id: doc.id,
        content: data['content'] ?? '',
        adminId: data['adminId'] ?? '',
        adminName: data['adminName'] ?? '',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    }).toList();

    return PaginatedResult(
      items: items,
      hasMore: hasMore,
      lastCursor: items.isNotEmpty ? items.last.id : null,
    );
  }

  @override
  Future<List<UserSession>> getUserSessions(String uid) async {
    final snap = await _firestore
        .collection(AdminConstants.usersCollection)
        .doc(uid)
        .collection(AdminConstants.sessionsSubcollection)
        .orderBy('lastActive', descending: true)
        .limit(20)
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      DateTime? lastActive;
      if (data['lastActive'] is Timestamp) {
        lastActive = (data['lastActive'] as Timestamp).toDate();
      }
      return UserSession(
        id: doc.id,
        platform: data['platform'] ?? 'unknown',
        lastActive: lastActive,
        active: data['active'] ?? true,
      );
    }).toList();
  }

  @override
  Future<AppSettings> getAppSettings() async {
    final doc = await _firestore
        .collection(AdminConstants.systemSettingsCollection)
        .doc(AdminConstants.appVersionDoc)
        .get();
    if (!doc.exists) return const AppSettings();
    final data = doc.data() ?? {};
    return AppSettings(
      minSupportedVersion: data['minSupportedVersion'] ?? '1.0.0',
      latestVersion: data['latestVersion'] ?? '1.0.0',
      forceUpdate: data['forceUpdate'] ?? false,
    );
  }

  @override
  Future<PaginatedResult<BroadcastNotification>> getNotifications({
    int limit = AdminConstants.defaultPageSize,
    String? cursor,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(AdminConstants.notificationsCollection)
        .orderBy('createdAt', descending: true);

    if (cursor != null) {
      final cursorDoc = await _firestore
          .collection(AdminConstants.notificationsCollection)
          .doc(cursor)
          .get();
      if (cursorDoc.exists) query = query.startAfterDocument(cursorDoc);
    }

    final snap = await query.limit(limit + 1).get();
    final docs = snap.docs;
    final hasMore = docs.length > limit;
    final items = docs.take(limit).map((doc) {
      final data = doc.data();
      DateTime? createdAt;
      if (data['createdAt'] is Timestamp) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      }
      return BroadcastNotification(
        id: doc.id,
        title: data['title'] ?? '',
        body: data['body'] ?? '',
        targetType: data['targetType'] ?? 'all',
        targetIds: List<String>.from(data['targetIds'] ?? []),
        adminName: data['adminName'] ?? '',
        createdAt: createdAt,
      );
    }).toList();

    return PaginatedResult(
      items: items,
      hasMore: hasMore,
      lastCursor: items.isNotEmpty ? items.last.id : null,
    );
  }

  @override
  Future<Map<String, dynamic>> callFunction(
    String name, {
    Map<String, dynamic>? data,
  }) async {
    await _functions.ensureAuthToken();
    return _functions.call(name, data: data);
  }
}
