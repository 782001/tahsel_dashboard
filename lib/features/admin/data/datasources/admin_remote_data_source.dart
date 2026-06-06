import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tahsel_dashboard/core/constants/admin_constants.dart';
import 'package:tahsel_dashboard/core/constants/admin_permissions.dart';
import 'package:tahsel_dashboard/core/models/paginated_result.dart';
import 'package:tahsel_dashboard/features/admin/data/models/app_user_model.dart';
import 'package:tahsel_dashboard/features/admin/data/models/audit_log_model.dart';
import 'package:tahsel_dashboard/features/admin/data/models/dashboard_stats_model.dart';
import 'package:tahsel_dashboard/features/admin/data/services/admin_audit_service.dart';
import 'package:tahsel_dashboard/features/admin/data/services/admin_auth_service.dart';
import 'package:tahsel_dashboard/features/admin/data/services/admin_stats_service.dart';
import 'package:tahsel_dashboard/features/admin/data/utils/search_keywords_builder.dart';
import 'package:tahsel_dashboard/features/admin/data/utils/subscription_utils.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/admin_user.dart';
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
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data);
  Future<void> updateUser(Map<String, dynamic> data);
  Future<void> deleteUser(String uid);
  Future<void> suspendUser(String uid);
  Future<void> activateUser(String uid);
  Future<void> sendPasswordResetEmail(String uid);
  Future<void> forceLogout(String uid);
  Future<void> renewSubscription(String uid, int days);
  Future<void> extendSubscription(String uid, int days);
  Future<void> shortenSubscription(String uid, int days);
  Future<void> suspendSubscription(String uid);
  Future<void> reactivateSubscription(String uid);
  Future<void> createNote(String uid, String content);
  Future<void> updateNote(String uid, String noteId, String content);
  Future<void> deleteNote(String uid, String noteId);
  Future<void> sendNotification(Map<String, dynamic> data);
  Future<void> updateAppSettings(AppSettings settings);
  Future<void> setupInitialAdmin(String email, String name);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  AdminRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required AdminAuthService authService,
    required AdminAuditService auditService,
    required AdminStatsService statsService,
  })  : _firestore = firestore,
        _auth = auth,
        _authService = authService,
        _audit = auditService,
        _stats = statsService;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final AdminAuthService _authService;
  final AdminAuditService _audit;
  final AdminStatsService _stats;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _firestore.collection(AdminConstants.usersCollection).doc(uid);

  Future<AdminUser> _requireAdmin() async {
    final session = await verifySession();
    return AdminUser(
      uid: session['uid'] as String,
      email: session['email'] as String,
      name: session['name'] as String,
      role: session['role'] as String,
      permissions: (session['permissions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  void _requirePermission(AdminUser admin, String permission) {
    if (!AdminPermissions.has(admin.role, admin.permissions, permission)) {
      throw FirebaseException(
        plugin: 'admin',
        code: 'permission-denied',
        message: 'Missing permission: $permission',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> verifySession() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'unauthenticated', message: 'Not signed in');
    }
    final doc = await _firestore
        .collection(AdminConstants.adminsCollection)
        .doc(user.uid)
        .get();
    if (!doc.exists) {
      throw FirebaseException(
        plugin: 'admin',
        code: 'permission-denied',
        message: 'Admin access required',
      );
    }
    final data = doc.data() ?? {};
    if (data['active'] == false) {
      throw FirebaseException(
        plugin: 'admin',
        code: 'permission-denied',
        message: 'Admin account disabled',
      );
    }
    final role = data['role'] as String? ?? AdminPermissions.support;
    return {
      'uid': user.uid,
      'email': data['email'] ?? user.email ?? '',
      'name': data['name'] ?? '',
      'role': role,
      'permissions': data['permissions'] ?? AdminPermissions.forRole(role),
    };
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
      final cursorDoc = await _userRef(cursor).get();
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
      final cursorDoc = await _userRef(cursor).get();
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
      final cursorDoc = await _userRef(cursor).get();
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
    final doc = await _userRef(uid).get();
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
      final cursorDoc =
          await _firestore.collection(AdminConstants.auditLogsCollection).doc(cursor).get();
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
    Query<Map<String, dynamic>> query = _userRef(uid)
        .collection(AdminConstants.notesSubcollection)
        .orderBy('createdAt', descending: true);
    if (cursor != null) {
      final cursorDoc = await _userRef(uid)
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
      return UserNote(
        id: doc.id,
        content: data['content'] ?? '',
        adminId: data['adminId'] ?? '',
        adminName: data['adminName'] ?? '',
        createdAt: _toDate(data['createdAt']),
        updatedAt: _toDate(data['updatedAt']),
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
    final snap = await _userRef(uid)
        .collection(AdminConstants.sessionsSubcollection)
        .orderBy('lastActive', descending: true)
        .limit(20)
        .get();
    return snap.docs.map((doc) {
      final data = doc.data();
      return UserSession(
        id: doc.id,
        platform: data['platform'] ?? 'unknown',
        lastActive: _toDate(data['lastActive']),
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
      return BroadcastNotification(
        id: doc.id,
        title: data['title'] ?? '',
        body: data['body'] ?? '',
        targetType: data['targetType'] ?? 'all',
        targetIds: List<String>.from(data['targetIds'] ?? []),
        adminName: data['adminName'] ?? '',
        createdAt: _toDate(data['createdAt']),
      );
    }).toList();
    return PaginatedResult(
      items: items,
      hasMore: hasMore,
      lastCursor: items.isNotEmpty ? items.last.id : null,
    );
  }

  @override
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    final admin = await _requireAdmin();
    _requirePermission(admin, AdminPermissions.usersWrite);

    final email = (data['email'] as String).trim();
    final password = data['password'] as String;
    final fullName = (data['fullName'] as String).trim();
    final phoneNumber = data['phoneNumber'] as String?;
    final days = data['subscriptionDays'] as int? ?? 30;

    final credential = await _authService.createAuthUser(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    final now = Timestamp.now();
    final endDate = Timestamp.fromDate(
      DateTime.now().add(Duration(days: days)),
    );

    final userDoc = {
      'uid': uid,
      'fullName': fullName,
      'email': email.toLowerCase(),
      'phoneNumber': phoneNumber ?? '',
      'accountStatus': 'active',
      'subscriptionStatus': 'active',
      'subscriptionSuspended': false,
      'subscriptionStart': now,
      'subscriptionEnd': endDate,
      'createdAt': now,
      'lastLogin': null,
      'lastActive': null,
      'devicePlatform': null,
      'deletedAt': null,
      'forceLogoutAt': null,
      'searchKeywords': SearchKeywordsBuilder.build(
        uid: uid,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
      ),
      'stats': {
        'customers': 0,
        'debts': 0,
        'employees': 0,
        'transactions': 0,
        'expenses': 0,
      },
    };

    await _userRef(uid).set(userDoc);
    await _audit.log(
      admin: admin,
      actionType: 'CREATE_USER',
      targetUserId: uid,
      targetUserName: fullName,
      metadata: {'email': email, 'subscriptionDays': days},
    );
    await _stats.refresh();
    return {...userDoc, 'uid': uid};
  }

  @override
  Future<void> updateUser(Map<String, dynamic> data) async {
    final admin = await _requireAdmin();
    _requirePermission(admin, AdminPermissions.usersWrite);

    final uid = data['uid'] as String;
    final userSnap = await _userRef(uid).get();
    if (!userSnap.exists) throw Exception('User not found');

    final current = userSnap.data()!;
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (data['fullName'] != null) updates['fullName'] = data['fullName'];
    if (data['phoneNumber'] != null) updates['phoneNumber'] = data['phoneNumber'];
    if (data['email'] != null) updates['email'] = (data['email'] as String).toLowerCase();

    updates['searchKeywords'] = SearchKeywordsBuilder.build(
      uid: uid,
      fullName: updates['fullName'] as String? ?? current['fullName'] as String?,
      email: updates['email'] as String? ?? current['email'] as String?,
      phoneNumber: updates['phoneNumber'] as String? ?? current['phoneNumber'] as String?,
    );

    await _userRef(uid).update(updates);
    await _audit.log(
      admin: admin,
      actionType: 'UPDATE_USER',
      targetUserId: uid,
      targetUserName: updates['fullName'] as String? ?? current['fullName'] as String?,
      metadata: updates,
    );
  }

  @override
  Future<void> deleteUser(String uid) async {
    final admin = await _requireAdmin();
    _requirePermission(admin, AdminPermissions.usersWrite);

    final userSnap = await _userRef(uid).get();
    if (!userSnap.exists) throw Exception('User not found');
    final name = userSnap.data()?['fullName'] as String?;

    await _userRef(uid).update({
      'accountStatus': 'deleted',
      'deletedAt': FieldValue.serverTimestamp(),
      'subscriptionStatus': 'expired',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _audit.log(
      admin: admin,
      actionType: 'DELETE_USER',
      targetUserId: uid,
      targetUserName: name,
    );
    await _stats.refresh();
  }

  @override
  Future<void> suspendUser(String uid) async {
    final admin = await _requireAdmin();
    _requirePermission(admin, AdminPermissions.usersWrite);

    final userSnap = await _userRef(uid).get();
    if (!userSnap.exists) throw Exception('User not found');

    await _userRef(uid).update({
      'accountStatus': 'suspended',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _audit.log(
      admin: admin,
      actionType: 'SUSPEND_USER',
      targetUserId: uid,
      targetUserName: userSnap.data()?['fullName'] as String?,
    );
    await _stats.refresh();
  }

  @override
  Future<void> activateUser(String uid) async {
    final admin = await _requireAdmin();
    _requirePermission(admin, AdminPermissions.usersWrite);

    final userSnap = await _userRef(uid).get();
    if (!userSnap.exists) throw Exception('User not found');
    final data = userSnap.data()!;

    final subscriptionStatus = SubscriptionUtils.computeStatus(
      subscriptionEnd: _toDate(data['subscriptionEnd']),
      accountStatus: 'active',
      subscriptionSuspended: data['subscriptionSuspended'] == true,
    );

    await _userRef(uid).update({
      'accountStatus': 'active',
      'subscriptionStatus': subscriptionStatus,
      'deletedAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _audit.log(
      admin: admin,
      actionType: 'ACTIVATE_USER',
      targetUserId: uid,
      targetUserName: data['fullName'] as String?,
    );
    await _stats.refresh();
  }

  @override
  Future<void> sendPasswordResetEmail(String uid) async {
    final admin = await _requireAdmin();
    _requirePermission(admin, AdminPermissions.usersWrite);

    final userSnap = await _userRef(uid).get();
    if (!userSnap.exists) throw Exception('User not found');
    final email = userSnap.data()?['email'] as String?;
    if (email == null || email.isEmpty) throw Exception('User email not found');

    await _authService.sendPasswordResetEmail(email);

    await _audit.log(
      admin: admin,
      actionType: 'RESET_PASSWORD',
      targetUserId: uid,
      targetUserName: userSnap.data()?['fullName'] as String?,
      metadata: {'method': 'password_reset_email'},
    );
  }

  @override
  Future<void> forceLogout(String uid) async {
    final admin = await _requireAdmin();
    _requirePermission(admin, AdminPermissions.usersWrite);

    final userSnap = await _userRef(uid).get();
    if (!userSnap.exists) throw Exception('User not found');

    await _userRef(uid).update({
      'forceLogoutAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final sessionsSnap = await _userRef(uid)
        .collection(AdminConstants.sessionsSubcollection)
        .get();
    final batch = _firestore.batch();
    for (final doc in sessionsSnap.docs) {
      batch.update(doc.reference, {
        'active': false,
        'revokedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();

    await _audit.log(
      admin: admin,
      actionType: 'FORCE_LOGOUT',
      targetUserId: uid,
      targetUserName: userSnap.data()?['fullName'] as String?,
    );
  }

  Future<void> _applySubscriptionUpdate({
    required AdminUser admin,
    required String uid,
    required Map<String, dynamic> updates,
    required String actionType,
    Map<String, dynamic>? metadata,
  }) async {
    _requirePermission(admin, AdminPermissions.subscriptionsWrite);
    final userSnap = await _userRef(uid).get();
    if (!userSnap.exists) throw Exception('User not found');

    await _userRef(uid).update({
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _audit.log(
      admin: admin,
      actionType: actionType,
      targetUserId: uid,
      targetUserName: userSnap.data()?['fullName'] as String?,
      metadata: metadata,
    );
    await _stats.refresh();
  }

  @override
  Future<void> renewSubscription(String uid, int days) async {
    final admin = await _requireAdmin();
    final now = Timestamp.now();
    final endDate = Timestamp.fromDate(DateTime.now().add(Duration(days: days)));
    await _applySubscriptionUpdate(
      admin: admin,
      uid: uid,
      updates: {
        'subscriptionStart': now,
        'subscriptionEnd': endDate,
        'subscriptionSuspended': false,
        'subscriptionStatus': 'active',
      },
      actionType: 'RENEW_SUBSCRIPTION',
      metadata: {'days': days},
    );
  }

  @override
  Future<void> extendSubscription(String uid, int days) async {
    final admin = await _requireAdmin();
    final userSnap = await _userRef(uid).get();
    final data = userSnap.data()!;
    final currentEnd = _toDate(data['subscriptionEnd']) ?? DateTime.now();
    final base = currentEnd.isAfter(DateTime.now()) ? currentEnd : DateTime.now();
    final newEnd = SubscriptionUtils.addDays(base, days);
    final status = SubscriptionUtils.computeStatus(
      subscriptionEnd: newEnd,
      accountStatus: data['accountStatus'] as String? ?? 'active',
      subscriptionSuspended: false,
    );
    await _applySubscriptionUpdate(
      admin: admin,
      uid: uid,
      updates: {
        'subscriptionEnd': Timestamp.fromDate(newEnd),
        'subscriptionStatus': status,
        'subscriptionSuspended': false,
      },
      actionType: 'EXTEND_SUBSCRIPTION',
      metadata: {'days': days},
    );
  }

  @override
  Future<void> shortenSubscription(String uid, int days) async {
    final admin = await _requireAdmin();
    final userSnap = await _userRef(uid).get();
    final data = userSnap.data()!;
    final currentEnd = _toDate(data['subscriptionEnd']) ?? DateTime.now();
    final newEnd = SubscriptionUtils.addDays(currentEnd, -days);
    final status = SubscriptionUtils.computeStatus(
      subscriptionEnd: newEnd,
      accountStatus: data['accountStatus'] as String? ?? 'active',
      subscriptionSuspended: data['subscriptionSuspended'] == true,
    );
    await _applySubscriptionUpdate(
      admin: admin,
      uid: uid,
      updates: {
        'subscriptionEnd': Timestamp.fromDate(newEnd),
        'subscriptionStatus': status,
      },
      actionType: 'SHORTEN_SUBSCRIPTION',
      metadata: {'daysRemoved': days},
    );
  }

  @override
  Future<void> suspendSubscription(String uid) async {
    final admin = await _requireAdmin();
    await _applySubscriptionUpdate(
      admin: admin,
      uid: uid,
      updates: {
        'subscriptionSuspended': true,
        'subscriptionStatus': 'suspended',
      },
      actionType: 'SUSPEND_SUBSCRIPTION',
    );
  }

  @override
  Future<void> reactivateSubscription(String uid) async {
    final admin = await _requireAdmin();
    final userSnap = await _userRef(uid).get();
    final data = userSnap.data()!;
    final status = SubscriptionUtils.computeStatus(
      subscriptionEnd: _toDate(data['subscriptionEnd']),
      accountStatus: data['accountStatus'] as String? ?? 'active',
      subscriptionSuspended: false,
    );
    await _applySubscriptionUpdate(
      admin: admin,
      uid: uid,
      updates: {
        'subscriptionSuspended': false,
        'subscriptionStatus': status,
      },
      actionType: 'REACTIVATE_SUBSCRIPTION',
    );
  }

  @override
  Future<void> createNote(String uid, String content) async {
    final admin = await _requireAdmin();
    _requirePermission(admin, AdminPermissions.usersWrite);

    final userSnap = await _userRef(uid).get();
    if (!userSnap.exists) throw Exception('User not found');

    final noteRef = _userRef(uid).collection(AdminConstants.notesSubcollection).doc();
    await noteRef.set({
      'id': noteRef.id,
      'content': content.trim(),
      'adminId': admin.uid,
      'adminName': admin.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _audit.log(
      admin: admin,
      actionType: 'CREATE_NOTE',
      targetUserId: uid,
      targetUserName: userSnap.data()?['fullName'] as String?,
      metadata: {'noteId': noteRef.id},
    );
  }

  @override
  Future<void> updateNote(String uid, String noteId, String content) async {
    final admin = await _requireAdmin();
    _requirePermission(admin, AdminPermissions.usersWrite);

    final noteRef =
        _userRef(uid).collection(AdminConstants.notesSubcollection).doc(noteId);
    if (!(await noteRef.get()).exists) throw Exception('Note not found');

    await noteRef.update({
      'content': content.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _audit.log(
      admin: admin,
      actionType: 'UPDATE_NOTE',
      targetUserId: uid,
      metadata: {'noteId': noteId},
    );
  }

  @override
  Future<void> deleteNote(String uid, String noteId) async {
    final admin = await _requireAdmin();
    _requirePermission(admin, AdminPermissions.usersWrite);

    final noteRef =
        _userRef(uid).collection(AdminConstants.notesSubcollection).doc(noteId);
    if (!(await noteRef.get()).exists) throw Exception('Note not found');

    await noteRef.delete();
    await _audit.log(
      admin: admin,
      actionType: 'DELETE_NOTE',
      targetUserId: uid,
      metadata: {'noteId': noteId},
    );
  }

  @override
  Future<void> sendNotification(Map<String, dynamic> data) async {
    final admin = await _requireAdmin();
    _requirePermission(admin, AdminPermissions.notificationsWrite);

    final ref = _firestore.collection(AdminConstants.notificationsCollection).doc();
    await ref.set({
      'id': ref.id,
      'title': data['title'],
      'body': data['body'],
      'targetType': data['targetType'] ?? 'all',
      'targetIds': data['targetIds'] ?? [],
      'groupFilter': data['groupFilter'],
      'adminId': admin.uid,
      'adminName': admin.name,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'sent',
    });

    await _audit.log(
      admin: admin,
      actionType: 'SEND_NOTIFICATION',
      metadata: {
        'notificationId': ref.id,
        'targetType': data['targetType'],
      },
    );
  }

  @override
  Future<void> updateAppSettings(AppSettings settings) async {
    final admin = await _requireAdmin();
    _requirePermission(admin, AdminPermissions.settingsWrite);

    await _firestore
        .collection(AdminConstants.systemSettingsCollection)
        .doc(AdminConstants.appVersionDoc)
        .set({
      'minSupportedVersion': settings.minSupportedVersion,
      'latestVersion': settings.latestVersion,
      'forceUpdate': settings.forceUpdate,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': admin.uid,
    }, SetOptions(merge: true));

    await _audit.log(
      admin: admin,
      actionType: 'UPDATE_SETTINGS',
      metadata: {
        'minSupportedVersion': settings.minSupportedVersion,
        'latestVersion': settings.latestVersion,
        'forceUpdate': settings.forceUpdate,
      },
    );
  }

  @override
  Future<void> setupInitialAdmin(String email, String name) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'unauthenticated', message: 'Sign in first');
    }

    final configRef = _firestore.collection('system').doc('config');
    final configSnap = await configRef.get();
    final bootstrapOpen = configSnap.data()?['bootstrapOpen'] == true;

    final adminRef =
        _firestore.collection(AdminConstants.adminsCollection).doc(user.uid);
    if ((await adminRef.get()).exists) {
      throw Exception('Admin profile already exists');
    }
    if (!bootstrapOpen) {
      throw Exception(
        'Bootstrap is closed. Set system/config.bootstrapOpen=true in Firestore once, '
        'or ask an existing super_admin to create your admin profile.',
      );
    }

    final role = AdminPermissions.superAdmin;
    final batch = _firestore.batch();
    batch.set(adminRef, {
      'uid': user.uid,
      'email': email,
      'name': name,
      'role': role,
      'permissions': AdminPermissions.forRole(role),
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(configRef, {
      'bootstrapOpen': false,
      'bootstrapCompletedAt': FieldValue.serverTimestamp(),
      'bootstrapCompletedBy': user.uid,
    }, SetOptions(merge: true));
    await batch.commit();
  }

  DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
