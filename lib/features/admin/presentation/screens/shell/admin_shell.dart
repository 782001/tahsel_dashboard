import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
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
    UsersListScreen(), AdminDashboardScreen(),

    ExpirationScreen(),
    AuditLogsScreen(),
    // NotificationsScreen(),
    SystemSettingsScreen(),
  ];

  List<_NavItem> get _navItems => [
    _NavItem('admin_nav_users'.tr(), Icons.people_outline),
    _NavItem('admin_nav_dashboard'.tr(), Icons.dashboard_outlined),

    _NavItem('admin_nav_expiration'.tr(), Icons.schedule),
    _NavItem('admin_nav_audit'.tr(), Icons.history),
    // _NavItem('admin_nav_notifications'.tr(), Icons.campaign_outlined),
    _NavItem('admin_nav_settings'.tr(), Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: AppColors.scafoldBackGround,
      body: Row(
        children: [
          if (isWide) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(isWide),
                Expanded(child: _screens[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              destinations: _navItems
                  .map(
                    (n) => NavigationDestination(
                      icon: Icon(n.icon),
                      label: n.label,
                    ),
                  )
                  .toList(),
            ),
      drawer: isWide ? null : Drawer(child: _buildSidebar()),
    );
  }

  Widget _buildSidebar() {
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
          SizedBox(height: 24.h),
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final selected = _selectedIndex == index;
                return ListTile(
                  selected: selected,
                  selectedTileColor: AppColors.primaryColor.withValues(
                    alpha: 0.1,
                  ),
                  leading: Icon(
                    item.icon,
                    color: selected
                        ? AppColors.primaryColor
                        : AppColors.subTitleColor,
                  ),
                  title: TextWidget(
                    item.label,
                    style: TextStyles.font14Weight400RightAligned().copyWith(
                      color: selected
                          ? AppColors.primaryColor
                          : AppColors.textColor,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  onTap: () => setState(() => _selectedIndex = index),
                );
              },
            ),
          ),
          const LanguageSection(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: TextWidget('logout'.tr()),
            onTap: () => context.read<AuthCubit>().logout(),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isWide) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: AppColors.surface,
      child: Row(
        children: [
          if (!isWide)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
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
            icon: const Icon(Icons.logout),
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
  _NavItem(this.label, this.icon);
}
