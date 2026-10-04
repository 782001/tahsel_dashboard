/// Role-based permissions enforced in Firestore rules and mirrored client-side.
class AdminPermissions {
  AdminPermissions._();

  static const usersRead = 'users.read';
  static const usersWrite = 'users.write';
  static const subscriptionsWrite = 'subscriptions.write';
  static const subscriptionsRead = 'subscriptions.read';
  static const notificationsWrite = 'notifications.write';
  static const notificationsRead = 'notifications.read';
  static const auditRead = 'audit.read';
  static const auditWrite = 'audit.write';
  static const settingsRead = 'settings.read';
  static const settingsWrite = 'settings.write';
  static const adminsWrite = 'admins.write';

  static const superAdmin = 'super_admin';
  static const admin = 'admin';
  static const support = 'support';
  static const custom = 'custom';

  static List<String> forRole(String role) {
    switch (role) {
      case superAdmin:
        return ['*'];
      case admin:
        return [
          usersRead,
          usersWrite,
          subscriptionsWrite,
          subscriptionsRead,
          notificationsWrite,
          notificationsRead,
          auditRead,
          auditWrite,
          settingsRead,
        ];
      case support:
        return [
          usersRead,
          subscriptionsRead,
          notificationsRead,
          auditRead,
        ];
      default:
        return [];
    }
  }

  static bool isSuperAdmin(String role, [List<String>? stored, String? email]) {
    if (email != null &&
        email.toLowerCase().trim() == 'admin@tahsel.com') {
      return true;
    }
    if (role == superAdmin) return true;
    final perms = stored ?? forRole(role);
    return perms.contains('*');
  }

  static bool has(
    String role,
    List<String>? stored,
    String permission, {
    String? email,
  }) {
    if (email != null &&
        email.toLowerCase().trim() == 'admin@tahsel.com') {
      return true;
    }
    if (role == superAdmin) return true;
    final perms = stored ?? forRole(role);
    if (perms.contains('*')) return true;
    return perms.contains(permission);
  }

  static bool canWriteUsers(String role, [List<String>? stored, String? email]) =>
      has(role, stored, usersWrite, email: email);

  static bool canReadUsers(String role, [List<String>? stored, String? email]) =>
      has(role, stored, usersRead, email: email);

  static bool canWriteSubscriptions(
          String role, [List<String>? stored, String? email]) =>
      has(role, stored, subscriptionsWrite, email: email);

  static bool canReadSubscriptions(
          String role, [List<String>? stored, String? email]) =>
      has(role, stored, subscriptionsRead, email: email);

  static bool canWriteNotifications(
          String role, [List<String>? stored, String? email]) =>
      has(role, stored, notificationsWrite, email: email);

  static bool canReadNotifications(
          String role, [List<String>? stored, String? email]) =>
      has(role, stored, notificationsRead, email: email);

  static bool canWriteSettings(
          String role, [List<String>? stored, String? email]) =>
      has(role, stored, settingsWrite, email: email);

  static bool canReadSettings(
          String role, [List<String>? stored, String? email]) =>
      has(role, stored, settingsRead, email: email);

  static bool canWriteAudit(
          String role, [List<String>? stored, String? email]) =>
      has(role, stored, auditWrite, email: email);

  static bool canReadAudit(
          String role, [List<String>? stored, String? email]) =>
      has(role, stored, auditRead, email: email);

  static bool canManageAdmins(
          String role, [List<String>? stored, String? email]) =>
      email?.toLowerCase().trim() == 'admin@tahsel.com';
}

