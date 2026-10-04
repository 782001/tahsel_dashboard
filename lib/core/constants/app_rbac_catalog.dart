import 'app_permissions.dart';

export 'app_permissions.dart';

class AppPermissionItem {
  final String key;
  final String titleAr;
  final String titleEn;

  const AppPermissionItem({
    required this.key,
    required this.titleAr,
    required this.titleEn,
  });
}

class AppPermissionGroup {
  final String id;
  final String titleAr;
  final String titleEn;
  final List<AppPermissionItem> items;

  const AppPermissionGroup({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.items,
  });
}

/// Backwards-compatible RBAC catalog mapped directly to the complete Tahsel AppPermissions.
class AppRbacCatalog {
  AppRbacCatalog._();

  static const String roleCashier = AppPermissions.roleCashier;
  static const String roleStorekeeper = AppPermissions.roleStorekeeper;
  static const String roleAccountant = AppPermissions.roleAccountant;
  static const String roleSupervisor = AppPermissions.roleSupervisor;
  static const String roleCustom = AppPermissions.roleCustom;

  static List<AppPermissionGroup> get groups => AppPermissions.allGroups
      .map(
        (g) => AppPermissionGroup(
          id: g.id,
          titleAr: g.titleAr,
          titleEn: g.titleEn,
          items: g.items
              .map(
                (i) => AppPermissionItem(
                  key: i.key,
                  titleAr: i.titleAr,
                  titleEn: i.titleEn,
                ),
              )
              .toList(),
        ),
      )
      .toList();

  static int get totalPermissions => AppPermissions.totalPermissions;

  static const Map<String, List<String>> permissionDependencies =
      AppPermissions.permissionDependencies;

  static Set<String> getPrerequisites(String permission) =>
      AppPermissions.getPrerequisites(permission);

  static Set<String> getDependents(String permission) =>
      AppPermissions.getDependents(permission);

  static Set<String> resolveDependencies(Iterable<String> permissions) =>
      AppPermissions.resolveDependencies(permissions);

  static List<String> permissionsForPreset(String preset, {bool isShop = true}) =>
      AppPermissions.permissionsForPreset(preset, isShop: isShop);

  static String getRoleLabel(String preset) =>
      AppPermissions.getRoleLabel(preset);

  static bool hasPrerequisites(String permission) =>
      AppPermissions.hasPrerequisites(permission);

  static String getPermissionLabel(String key, {bool isArabic = true}) =>
      AppPermissions.getPermissionLabel(key, isArabic: isArabic);

  static String getPrerequisiteLabels(String permission, {bool isArabic = true}) =>
      AppPermissions.getPrerequisiteLabels(permission, isArabic: isArabic);
}
