import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
import 'package:tahsel_dashboard/core/utils/app_constants.dart';
import 'package:tahsel_dashboard/core/utils/styles.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/auth/auth_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/screens/audit/audit_logs_screen.dart';
import 'package:tahsel_dashboard/features/admin/presentation/screens/dashboard/admin_dashboard_screen.dart';
import 'package:tahsel_dashboard/features/admin/presentation/screens/expiration/expiration_screen.dart';
import 'package:tahsel_dashboard/features/admin/presentation/screens/settings/system_settings_screen.dart';
import 'package:tahsel_dashboard/features/admin/presentation/screens/users/users_list_screen.dart';
import 'package:tahsel_dashboard/features/standard_features/localization/presentation/widgets/language_section.dart';
import 'package:tahsel_dashboard/shared/widgets/buttons/theme_toggle_button.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  final _screens = const [
    UsersListScreen(),
    AdminDashboardScreen(),
    ExpirationScreen(),
    AuditLogsScreen(),
    SystemSettingsScreen(),
  ];

  List<_NavItem> get _navItems => [
    _NavItem(
      'admin_nav_users'.tr(),
      Icons.people_outline_rounded,
      Icons.people_rounded,
    ),
    _NavItem(
      'admin_nav_dashboard'.tr(),
      Icons.dashboard_outlined,
      Icons.dashboard_rounded,
    ),
    _NavItem(
      'admin_nav_expiration'.tr(),
      Icons.schedule_outlined,
      Icons.schedule_rounded,
    ),
    _NavItem(
      'admin_nav_audit'.tr(),
      Icons.history_rounded,
      Icons.manage_history_rounded,
    ),
    _NavItem(
      'admin_nav_settings'.tr(),
      Icons.settings_outlined,
      Icons.settings_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.scafoldBackGround,
      body: Row(
        children: [
          if (isWide) _buildSidebar(isDrawer: false),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(isWide, isDark),
                Expanded(child: _screens[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWide ? null : _buildBottomNavBar(context, isDark),
      drawer: isWide ? null : Drawer(child: _buildSidebar(isDrawer: true)),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, bool isDark) {
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
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = _selectedIndex == index;

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

  Widget _buildSidebar({bool isDrawer = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 240.w,
      color: AppColors.surface,
      child: Column(
        children: [
          SizedBox(height: 24.h),
          TextWidget(
            'admin_panel_title'.tr(),
            style: TextStyles.font18Weight500Action(),
          ),
          SizedBox(height: 20.h),
          Divider(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
            height: 1,
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final selected = _selectedIndex == index;
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

  Widget _buildTopBar(bool isWide, bool isDark) {
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
              _navItems[_selectedIndex].label,
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

class _NavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _NavItem(this.label, this.icon, [IconData? selectedIcon])
      : selectedIcon = selectedIcon ?? icon;
}

