import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tahsel_dashboard/core/services/injection_container.dart';
import 'package:tahsel_dashboard/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:tahsel_dashboard/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:tahsel_dashboard/features/admin/data/services/admin_audit_service.dart';
import 'package:tahsel_dashboard/features/admin/data/services/admin_auth_service.dart';
import 'package:tahsel_dashboard/features/admin/data/services/admin_stats_service.dart';
import 'package:tahsel_dashboard/features/admin/domain/repositories/admin_repository.dart';
import 'package:tahsel_dashboard/features/admin/domain/usecases/admin_usecases.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/audit/audit_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/auth/auth_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/dashboard/dashboard_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/notifications/notifications_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/settings/settings_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/user_detail/user_detail_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/users/users_cubit.dart';

void registerAdminDependencies() {
  sl.registerLazySingleton<AdminAuthService>(() => AdminAuthService());
  sl.registerLazySingleton<AdminAuditService>(
    () => AdminAuditService(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<AdminStatsService>(
    () => AdminStatsService(sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
      auth: sl<FirebaseAuth>(),
      authService: sl<AdminAuthService>(),
      auditService: sl<AdminAuditService>(),
      statsService: sl<AdminStatsService>(),
    ),
  );

  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(sl<AdminRemoteDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInAdminUseCase(sl()));
  sl.registerLazySingleton(() => VerifyAdminSessionUseCase(sl()));
  sl.registerLazySingleton(() => SignOutAdminUseCase(sl()));
  sl.registerLazySingleton(() => GetDashboardStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetUsersUseCase(sl()));
  sl.registerLazySingleton(() => SearchUsersUseCase(sl()));
  sl.registerLazySingleton(() => GetExpiringUsersUseCase(sl()));
  sl.registerLazySingleton(() => GetUserByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetAuditLogsUseCase(sl()));
  sl.registerLazySingleton(() => CreateUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserUseCase(sl()));
  sl.registerLazySingleton(() => DeleteUserUseCase(sl()));
  sl.registerLazySingleton(() => SuspendUserUseCase(sl()));
  sl.registerLazySingleton(() => ActivateUserUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ForceLogoutUseCase(sl()));
  sl.registerLazySingleton(() => SubscriptionActionUseCase(sl()));
  sl.registerLazySingleton(() => GetUserNotesUseCase(sl()));
  sl.registerLazySingleton(() => ManageNoteUseCase(sl()));
  sl.registerLazySingleton(() => GetUserSessionsUseCase(sl()));
  sl.registerLazySingleton(() => GetAppSettingsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAppSettingsUseCase(sl()));
  sl.registerLazySingleton(() => SendNotificationUseCase(sl()));
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => SetupInitialAdminUseCase(sl()));

  // Cubits
  sl.registerFactory(() => AuthCubit(
        signIn: sl(),
        verifySession: sl(),
        signOut: sl(),
        setupAdmin: sl(),
      ));
  sl.registerFactory(() => DashboardCubit(sl()));
  sl.registerFactory(() => UsersCubit(
        getUsers: sl(),
        searchUsers: sl(),
        createUser: sl(),
        deleteUser: sl(),
        suspendUser: sl(),
        activateUser: sl(),
      ));
  sl.registerFactory(() => ExpirationCubit(
        getExpiring: sl(),
        subscriptionAction: sl(),
      ));
  sl.registerFactory(() => UserDetailCubit(
        getUser: sl(),
        getNotes: sl(),
        getSessions: sl(),
        updateUser: sl(),
        deleteUser: sl(),
        suspendUser: sl(),
        activateUser: sl(),
        resetPassword: sl(),
        forceLogout: sl(),
        subscriptionAction: sl(),
        manageNote: sl(),
      ));
  sl.registerFactory(() => AuditCubit(sl()));
  sl.registerFactory(() => NotificationsCubit(
        getNotifications: sl(),
        sendNotification: sl(),
      ));
  sl.registerFactory(() => SettingsCubit(
        getSettings: sl(),
        updateSettings: sl(),
      ));
}
