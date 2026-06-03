class AdminConstants {
  AdminConstants._();

  static const int defaultPageSize = 15;
  static const int searchDebounceMs = 400;

  static const String usersCollection = 'users';
  static const String auditLogsCollection = 'audit_logs';
  static const String dashboardStatsCollection = 'dashboard_stats';
  static const String dashboardStatsDoc = 'summary';
  static const String systemSettingsCollection = 'system_settings';
  static const String appVersionDoc = 'app_version';
  static const String notificationsCollection = 'notifications';
  static const String adminsCollection = 'admins';
  static const String notesSubcollection = 'notes';
  static const String sessionsSubcollection = 'sessions';

  static const List<int> subscriptionPresets = [30, 60, 90];
  static const List<int> expirationWindows = [7, 14, 30];

  static const String roleSuperAdmin = 'super_admin';
  static const String roleAdmin = 'admin';
  static const String roleSupport = 'support';
}
