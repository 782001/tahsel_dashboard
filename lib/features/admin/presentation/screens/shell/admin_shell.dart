import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/extensions/auth_context_extensions.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
import 'package:tahsel_dashboard/core/utils/app_constants.dart';
import 'package:tahsel_dashboard/core/utils/styles.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/admin_user.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/auth/auth_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/screens/admins/admins_management_screen.dart';
import 'package:tahsel_dashboard/features/admin/presentation/screens/audit/audit_logs_screen.dart';
import 'package:tahsel_dashboard/features/admin/presentation/screens/dashboard/admin_dashboard_screen.dart';
import 'package:tahsel_dashboard/features/admin/presentation/screens/expiration/expiration_screen.dart';
import 'package:tahsel_dashboard/features/admin/presentation/screens/settings/system_settings_screen.dart';
import 'package:tahsel_dashboard/features/admin/presentation/screens/users/users_list_screen.dart';
import 'package:tahsel_dashboard/features/standard_features/localization/presentation/widgets/language_section.dart';
import 'package:tahsel_dashboard/shared/widgets/buttons/custom_button.dart';
import 'package:tahsel_dashboard/shared/widgets/buttons/theme_toggle_button.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  List<_ShellTabItem> _getPermittedTabs(AdminUser admin) {
    final allTabs = [
      _ShellTabItem(
        label: 'admin_nav_users'.tr(),
        icon: Icons.people_outline_rounded,
        selectedIcon: Icons.people_rounded,
        screen: const UsersListScreen(),
        isPermitted: (a) => a.canReadUsers,
      ),
      _ShellTabItem(
        label: 'admin_nav_dashboard'.tr(),
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
        screen: const AdminDashboardScreen(),
        isPermitted: (a) =>
            a.isSuperAdmin ||
            a.canReadUsers ||
            a.canReadSubscriptions ||
            a.canReadAudit,
      ),
      _ShellTabItem(
        label: 'admin_nav_expiration'.tr(),
        icon: Icons.schedule_outlined,
        selectedIcon: Icons.schedule_rounded,
        screen: const ExpirationScreen(),
        isPermitted: (a) => a.canReadSubscriptions,
      ),
      _ShellTabItem(
        label: 'admin_nav_admins'.tr(),
        icon: Icons.admin_panel_settings_outlined,
        selectedIcon: Icons.admin_panel_settings_rounded,
        screen: const AdminsManagementScreen(),
        isPermitted: (a) => a.isPrimarySuperAdmin,
      ),
      _ShellTabItem(
        label: 'admin_nav_audit'.tr(),
        icon: Icons.history_rounded,
        selectedIcon: Icons.manage_history_rounded,
        screen: const AuditLogsScreen(),
        isPermitted: (a) => a.canReadAudit,
      ),
      _ShellTabItem(
        label: 'admin_nav_settings'.tr(),
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings_rounded,
        screen: const SystemSettingsScreen(),
        isPermitted: (a) => a.canReadSettings,
      ),
    ];

    return allTabs.where((t) => t.isPermitted(admin)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final admin = context.watchAdmin;

    if (admin == null) {
      return Scaffold(
        backgroundColor: AppColors.scafoldBackGround,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final tabs = _getPermittedTabs(admin);

    if (tabs.isEmpty) {
      return _buildNoPermissionsScreen(context, admin);
    }

    final safeIndex = _selectedIndex.clamp(0, tabs.length - 1);

    return Scaffold(
      backgroundColor: AppColors.scafoldBackGround,
      body: Row(
        children: [
          if (isWide) _buildSidebar(context, admin, tabs, safeIndex, isDrawer: false),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(tabs, safeIndex, isWide, isDark),
                Expanded(child: tabs[safeIndex].screen),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          isWide ? null : _buildBottomNavBar(context, tabs, safeIndex, isDark),
      drawer: isWide
          ? null
          : Drawer(
              child: _buildSidebar(
                context,
                admin,
                tabs,
                safeIndex,
                isDrawer: true,
              ),
            ),
    );
  }

  Widget _buildNoPermissionsScreen(BuildContext context, AdminUser admin) {
    return Scaffold(
      backgroundColor: AppColors.scafoldBackGround,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(28.r),
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          constraints: BoxConstraints(maxWidth: 480.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_clock_rounded,
                  size: 48.sp,
                  color: AppColors.warning,
                ),
              ),
              SizedBox(height: 16.h),
              TextWidget(
                'لا توجد صلاحيات مفعّلة',
                style: TextStyles.font18Weight500Action().copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
              TextWidget(
                'حسابك (${admin.email}) مفعّل، ولكن لم يتم تعيين أي صلاحيات للنظام له. يرجى التواصل مع المدير العام لمنحك الصلاحيات المطلوبة.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.subTitleColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              CustomButton(
                text: 'logout'.tr(),
                color: AppColors.error,
                onPressed: () => context.read<AuthCubit>().logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(
    BuildContext context,
    List<_ShellTabItem> tabs,
    int safeIndex,
    bool isDark,
  ) {
    final activeColor = AppColors.primaryColor;
    final inactiveColor = isDark ? Colors.white54 : const Color(0xFF8A94A6);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.45)
                : const Color(0xFF1E56A0).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 66.h,
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Row(
            children: List.generate(tabs.length, (index) {
              final item = tabs[index];
              final isSelected = safeIndex == index;

              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedIndex = index);
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    splashColor: activeColor.withValues(alpha: 0.12),
                    highlightColor: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            padding: EdgeInsets.symmetric(
                              horizontal: isSelected ? 16.w : 6.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? activeColor.withValues(
                                      alpha: isDark ? 0.22 : 0.12,
                                    )
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: AnimatedScale(
                              scale: isSelected ? 1.08 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              child: Icon(
                                isSelected ? item.selectedIcon : item.icon,
                                size: 22.sp,
                                color: isSelected ? activeColor : inactiveColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: TextWidget(
                                item.label,
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontFamily: AppConstants.fontFamily,
                                  color: isSelected
                                      ? activeColor
                                      : inactiveColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    AdminUser admin,
    List<_ShellTabItem> tabs,
    int safeIndex, {
    bool isDrawer = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 250.w,
      color: AppColors.surface,
      child: Column(
        children: [
          SizedBox(height: 20.h),
          TextWidget(
            'admin_panel_title'.tr(),
            style: TextStyles.font18Weight500Action(),
          ),
          SizedBox(height: 14.h),

          // ─── Current Admin Profile Card ─────────────────────────────────
          Container(
            margin: EdgeInsets.symmetric(horizontal: 14.w),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.grey.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.primaryColor.withValues(alpha: 0.15),
                  child: TextWidget(
                    admin.name.isNotEmpty
                        ? admin.name[0].toUpperCase()
                        : 'A',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        admin.name.isNotEmpty ? admin.name : admin.email,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      _buildRoleBadge(admin),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),
          Divider(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
            height: 1,
          ),
          SizedBox(height: 10.h),

          // ─── Permitted Navigation Links ─────────────────────────────────
          Expanded(
            child: ListView.builder(
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final item = tabs[index];
                final selected = safeIndex == index;
                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryColor.withValues(
                            alpha: isDark ? 0.20 : 0.10,
                          )
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    dense: true,
                    leading: Icon(
                      selected ? item.selectedIcon : item.icon,
                      color: selected
                          ? AppColors.primaryColor
                          : (isDark ? Colors.white60 : AppColors.subTitleColor),
                    ),
                    title: TextWidget(
                      item.label,
                      style: TextStyles.font14Weight400RightAligned().copyWith(
                        color: selected
                            ? AppColors.primaryColor
                            : AppColors.textColor,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedIndex = index);
                      if (isDrawer && Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                );
              },
            ),
          ),

          if (admin.isPrimarySuperAdmin)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    color: const Color(0xFFD4AF37),
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextWidget(
                      'المالك الأساسي للنظام',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFB8860B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const LanguageSection(),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: TextWidget('logout'.tr()),
            onTap: () => context.read<AuthCubit>().logout(),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(AdminUser admin) {
    Color badgeColor;
    String badgeText = admin.roleDisplayName;

    if (admin.isPrimarySuperAdmin || admin.isSuperAdmin) {
      badgeColor = const Color(0xFFD4AF37);
    } else if (admin.role == 'admin') {
      badgeColor = AppColors.primaryColor;
    } else if (admin.role == 'support') {
      badgeColor = AppColors.success;
    } else {
      badgeColor = Colors.purple;
      if (admin.permissions != null) {
        badgeText = 'مخصص (${admin.permissions!.length})';
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: TextWidget(
        badgeText,
        style: TextStyle(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildTopBar(
    List<_ShellTabItem> tabs,
    int safeIndex,
    bool isWide,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (!isWide)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          Expanded(
            child: TextWidget(
              tabs[safeIndex].label,
              style: TextStyles.appbartext().copyWith(fontSize: 22.sp),
            ),
          ),
          const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
    );
  }
}

class _ShellTabItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget screen;
  final bool Function(AdminUser admin) isPermitted;

  const _ShellTabItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.screen,
    required this.isPermitted,
  });
}
