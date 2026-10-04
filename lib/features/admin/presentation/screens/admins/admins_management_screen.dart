import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/services/injection_container.dart';
import 'package:tahsel_dashboard/core/constants/admin_permissions.dart';
import 'package:tahsel_dashboard/core/extensions/auth_context_extensions.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
import 'package:tahsel_dashboard/core/utils/styles.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/dashboard_admin.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/admins/admins_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/admins/admins_state.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';
import 'package:tahsel_dashboard/shared/widgets/toast/custom_toast.dart';

class AdminsManagementScreen extends StatelessWidget {
  const AdminsManagementScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminsManagementScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!(context.watchAdmin?.isPrimarySuperAdmin ?? false)) {
      return Scaffold(
        backgroundColor: AppColors.scafoldBackGround,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 64.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 16.h),
                TextWidget(
                  'admins_access_denied_title'.tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: 8.h),
                TextWidget(
                  'admins_access_denied_desc'.tr(),
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BlocProvider<AdminsCubit>(
      create: (_) => sl<AdminsCubit>()..loadAdmins(),
      child: const _AdminsManagementView(),
    );
  }
}

class _AdminsManagementView extends StatefulWidget {
  const _AdminsManagementView();

  @override
  State<_AdminsManagementView> createState() => _AdminsManagementViewState();
}

class _AdminsManagementViewState extends State<_AdminsManagementView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!context.canManageAdmins) {
      return _buildAccessDenied();
    }

    return BlocConsumer<AdminsCubit, AdminsState>(
      listener: (context, state) {
        if (state is AdminActionSuccess) {
          showSuccessToast(state.message);
        } else if (state is AdminsError) {
          showfailureToast(state.message);
        }
      },
      builder: (context, state) {
        if (state is AdminsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final admins = state is AdminsLoaded
            ? state.admins
            : context.read<AdminsCubit>().currentAdmins;

        final filteredAdmins = admins.where((admin) {
          if (_searchQuery.isEmpty) return true;
          return admin.name.toLowerCase().contains(_searchQuery) ||
              admin.email.toLowerCase().contains(_searchQuery) ||
              admin.role.toLowerCase().contains(_searchQuery);
        }).toList();

        final totalAdmins = admins.length;
        final activeAdmins = admins.where((a) => a.active).length;
        final superAdmins = admins.where((a) => a.role == 'super_admin').length;

        return Scaffold(
          backgroundColor: AppColors.scafoldBackGround,
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'add_dashboard_admin_fab',
            onPressed: () => _showAddAdminDialog(context),
            backgroundColor: AppColors.primaryColor,
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
            ),
            label: TextWidget(
              'admins_create_admin'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<AdminsCubit>().loadAdmins();
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSuperAdminNotice(),
                        SizedBox(height: 14.h),
                        _buildStatCardsRow(
                          totalAdmins,
                          activeAdmins,
                          superAdmins,
                        ),
                        SizedBox(height: 16.h),
                        _buildSearchBar(),
                        SizedBox(height: 12.h),
                      ],
                    ),
                  ),
                ),
                if (filteredAdmins.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.admin_panel_settings_outlined,
                            size: 56.sp,
                            color: AppColors.subTitleColor.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          TextWidget(
                            'no_data'.tr(),
                            style: TextStyles.font16WeightBoldText().copyWith(
                              color: AppColors.subTitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 90.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final admin = filteredAdmins[index];
                        return _buildAdminCard(context, admin);
                      }, childCount: filteredAdmins.length),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccessDenied() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppColors.scafoldBackGround,
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 480.w),
          margin: EdgeInsets.all(24.r),
          padding: EdgeInsets.all(28.r),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black45 : Colors.black12,
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shield_outlined,
                  size: 48.sp,
                  color: AppColors.error,
                ),
              ),
              SizedBox(height: 16.h),
              TextWidget(
                'admins_access_denied_title'.tr(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              TextWidget(
                'admins_access_denied_desc'.tr(),
                style: TextStyles.font14Weight400RightAligned().copyWith(
                  color: AppColors.subTitleColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuperAdminNotice() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2A2000), const Color(0xFF1E1700)]
              : [const Color(0xFFFFF9E6), const Color(0xFFFFF3CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: const Color(0xFFD4AF37),
              size: 26.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  'admins_management_title'.tr(),
                  style: TextStyles.font16WeightBoldText().copyWith(
                    color: isDark
                        ? Colors.amber.shade200
                        : const Color(0xFF6B4E00),
                  ),
                ),
                SizedBox(height: 2.h),
                TextWidget(
                  'ميزة حصرية للمالك الأساسي (${DashboardAdmin.primaryAdminEmail})، أي حذف أو تعطيل يطرد الحساب فوراً من أي جهاز مفتوح.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.amber.shade100.withValues(alpha: 0.8)
                        : const Color(0xFF7A5C00),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardsRow(int total, int active, int superAdmins) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniStat(
            title: 'admins_total_count'.tr(),
            count: total.toString(),
            icon: Icons.group_rounded,
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildMiniStat(
            title: 'admins_active_count'.tr(),
            count: active.toString(),
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.green,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildMiniStat(
            title: 'سوبر أدمن',
            count: superAdmins.toString(),
            icon: Icons.verified_user_rounded,
            color: const Color(0xFFD4AF37),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(
                count,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 2,
              ),
              Icon(icon, size: 20.sp, color: color.withValues(alpha: 0.85)),
            ],
          ),
          SizedBox(height: 4.h),
          TextWidget(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.subTitleColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.subTitleColor.withValues(alpha: 0.15),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ابحث باسم الأدمن أو البريد الإلكتروني...',
          hintStyle: TextStyles.font14Weight400RightAligned().copyWith(
            color: AppColors.subTitleColor.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.primaryColor,
            size: 22.sp,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, DashboardAdmin admin) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPrimary = admin.isPrimarySuperAdmin;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isPrimary
              ? const Color(0xFFD4AF37).withValues(alpha: 0.5)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06)),
          width: isPrimary ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFF1E56A0).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24.r,
                      backgroundColor: isPrimary
                          ? const Color(0xFFD4AF37).withValues(alpha: 0.2)
                          : AppColors.primaryColor.withValues(alpha: 0.12),
                      child: Text(
                        admin.name.isNotEmpty
                            ? admin.name[0].toUpperCase()
                            : 'A',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: isPrimary
                              ? const Color(0xFFB8860B)
                              : AppColors.primaryColor,
                        ),
                      ),
                    ),
                    if (isPrimary)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Icon(
                          Icons.verified_rounded,
                          color: const Color(0xFFD4AF37),
                          size: 22.sp,
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextWidget(
                              admin.name,
                              style: TextStyles.font16WeightBoldText(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isPrimary) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFD4AF37,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: TextWidget(
                                'المالك الأساسي',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB8860B),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 3.h),
                      SelectableText(
                        admin.email,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.subTitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: admin.active
                            ? AppColors.green.withValues(alpha: 0.12)
                            : AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: TextWidget(
                        admin.active
                            ? 'admins_status_active'.tr()
                            : 'admins_status_inactive'.tr(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: admin.active
                              ? AppColors.green
                              : AppColors.error,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Switch.adaptive(
                      value: admin.active,
                      activeTrackColor: AppColors.primaryColor,
                      onChanged: isPrimary
                          ? null
                          : (val) {
                              context.read<AdminsCubit>().toggleStatus(
                                admin.uid,
                                val,
                              );
                            },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(
              height: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                _buildChip(
                  icon: Icons.security_rounded,
                  label: admin.roleDisplayArabic,
                  color: AppColors.primaryColor,
                ),
                SizedBox(width: 8.w),
                _buildChip(
                  icon: Icons.key_rounded,
                  label: admin.permissions.contains('*')
                      ? 'جميع الصلاحيات (*)'
                      : '${admin.permissions.length} صلاحيات',
                  color: const Color(0xFF7C4DFF),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isPrimary ||
                    (context.currentAdmin?.isPrimarySuperAdmin ?? false)) ...[
                  TextButton.icon(
                    onPressed: () => _showResetPasswordConfirm(context, admin),
                    icon: Icon(
                      Icons.lock_reset_rounded,
                      size: 18.sp,
                      color: AppColors.primaryColor,
                    ),
                    label: TextWidget(
                      'كلمة المرور',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  OutlinedButton.icon(
                    onPressed: () => _showEditAdminDialog(context, admin),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.primaryColor.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                    ),
                    icon: Icon(
                      Icons.edit_rounded,
                      size: 16.sp,
                      color: AppColors.primaryColor,
                    ),
                    label: TextWidget(
                      'تعديل',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (!isPrimary) ...[
                  SizedBox(width: 6.w),
                  ElevatedButton.icon(
                    onPressed: () => _showDeleteConfirmation(context, admin),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                    ),
                    icon: Icon(
                      Icons.delete_forever_rounded,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                    label: TextWidget(
                      'حذف',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          TextWidget(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Dialogs ─────────────────────────────────────────────────────────────

  void _showAddAdminDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogCtx) => _AddAdminDialog(
        onAdd: (name, email, password, role, permissions) {
          parentContext.read<AdminsCubit>().createAdmin(
            name: name,
            email: email,
            password: password,
            role: role,
            permissions: permissions,
          );
        },
      ),
    );
  }

  void _showEditAdminDialog(BuildContext parentContext, DashboardAdmin admin) {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogCtx) => _EditAdminDialog(
        admin: admin,
        onUpdate: (name, role, permissions) {
          parentContext.read<AdminsCubit>().updateAdmin(
            uid: admin.uid,
            name: name,
            role: role,
            permissions: permissions,
            active: admin.active,
          );
        },
      ),
    );
  }

  void _showResetPasswordConfirm(BuildContext context, DashboardAdmin admin) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.lock_reset_rounded,
              color: AppColors.primaryColor,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: TextWidget(
                'admins_send_reset_password'.tr(),
                style: TextStyles.font16WeightBoldText(),
              ),
            ),
          ],
        ),
        content: TextWidget(
          'هل تريد إرسال رابط تعيين كلمة المرور إلى البريد الإلكتروني الخاص بـ ${admin.name} (${admin.email})؟',
          style: TextStyles.font14Weight400RightAligned().copyWith(
            color: AppColors.subTitleColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: TextWidget('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminsCubit>().sendPasswordReset(admin.email);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: TextWidget(
              'إرسال الرابط',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, DashboardAdmin admin) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 28.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: TextWidget(
                'admins_delete_confirm_title'.tr(),
                style: TextStyles.font16WeightBoldText().copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              'admins_delete_confirm_desc'.tr(),
              style: TextStyles.font14Weight400RightAligned().copyWith(
                color: AppColors.textColor,
                height: 1.4,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.error,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextWidget(
                      'الأدمن: ${admin.name} (${admin.email})\nسيتم إنهاء جلسته فوراً من أي جهاز مفتوح.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: TextWidget('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminsCubit>().deleteAdmin(admin.uid);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: TextWidget(
              'حذف وطرد الحساب',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add Admin Dialog ────────────────────────────────────────────────────────

class _AddAdminDialog extends StatefulWidget {
  final void Function(
    String name,
    String email,
    String password,
    String role,
    List<String> permissions,
  )
  onAdd;

  const _AddAdminDialog({required this.onAdd});

  @override
  State<_AddAdminDialog> createState() => _AddAdminDialogState();
}

class _AddAdminDialogState extends State<_AddAdminDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String _selectedRole = AdminPermissions.superAdmin;
  late Set<String> _selectedPermissions;
  bool _obscurePassword = true;

  static const _availablePermissions = [
    {
      'key': AdminPermissions.usersRead,
      'label': 'استعراض المستخدمين',
      'desc': 'قراءة تفاصيل وبيانات العملاء',
    },
    {
      'key': AdminPermissions.usersWrite,
      'label': 'إدارة المستخدمين',
      'desc': 'إنشاء وتعديل وحذف المستخدمين والاشتراكات',
    },
    {
      'key': AdminPermissions.subscriptionsRead,
      'label': 'استعراض الاشتراكات',
      'desc': 'متابعة الاشتراكات والمنتهية',
    },
    {
      'key': AdminPermissions.subscriptionsWrite,
      'label': 'إدارة الاشتراكات',
      'desc': 'تجديد وتمديد وإيقاف الاشتراكات',
    },
    {
      'key': AdminPermissions.notificationsRead,
      'label': 'استعراض الإشعارات',
      'desc': 'قراءة سجل الإشعارات',
    },
    {
      'key': AdminPermissions.notificationsWrite,
      'label': 'إرسال الإشعارات',
      'desc': 'بث إشعارات عامة لجميع المستخدمين',
    },
    {
      'key': AdminPermissions.auditRead,
      'label': 'سجل النشاط والرقابة',
      'desc': 'مراقبة العمليات والإجراءات الإدارية',
    },
    {
      'key': AdminPermissions.settingsRead,
      'label': 'قراءة إعدادات النظام',
      'desc': 'استعراض إعدادات وإصدارات التطبيق',
    },
    {
      'key': AdminPermissions.settingsWrite,
      'label': 'تعديل إعدادات النظام',
      'desc': 'تحديث بيانات الإصدار وروابط التنزيل',
    },
    {
      'key': AdminPermissions.adminsWrite,
      'label': 'إدارة المدراء',
      'desc': 'إضافة وتعديل وحذف مدراء الداشبورد',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedPermissions = {'*'};
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onRoleChanged(String role) {
    setState(() {
      _selectedRole = role;
      if (role == AdminPermissions.superAdmin) {
        _selectedPermissions = {'*'};
      } else if (role == AdminPermissions.admin) {
        _selectedPermissions = {
          AdminPermissions.usersRead,
          AdminPermissions.usersWrite,
          AdminPermissions.subscriptionsRead,
          AdminPermissions.subscriptionsWrite,
          AdminPermissions.notificationsRead,
          AdminPermissions.notificationsWrite,
          AdminPermissions.auditRead,
          AdminPermissions.settingsRead,
        };
      } else if (role == AdminPermissions.support) {
        _selectedPermissions = {
          AdminPermissions.usersRead,
          AdminPermissions.subscriptionsRead,
          AdminPermissions.notificationsRead,
          AdminPermissions.auditRead,
        };
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        width: 600.w,
        constraints: BoxConstraints(maxHeight: 700.h),
        padding: EdgeInsets.all(20.r),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add_rounded,
                      color: AppColors.primaryColor,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: TextWidget(
                      'admins_create_admin'.tr(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        'الاسم الكامل',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          hintText: 'مثال: أحمد محمد',
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'يرجى إدخال الاسم'
                            : null,
                      ),
                      SizedBox(height: 12.h),
                      TextWidget(
                        'البريد الإلكتروني',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'مثال: manager@tahsel.com',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'يرجى إدخال البريد الإلكتروني';
                          }
                          if (!v.contains('@')) {
                            return 'يرجى إدخال بريد إلكتروني صالح';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12.h),
                      TextWidget(
                        'كلمة المرور الأولية (6 أحرف فأكثر)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '******',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        validator: (v) => v == null || v.length < 6
                            ? 'كلمة المرور يجب ألا تقل عن 6 أحرف'
                            : null,
                      ),
                      SizedBox(height: 16.h),
                      TextWidget(
                        'نوع الدور والصلاحيات',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          _buildRoleChoiceChip(
                            label: 'سوبر أدمن (شامل)',
                            role: AdminPermissions.superAdmin,
                            icon: Icons.workspace_premium_rounded,
                          ),
                          _buildRoleChoiceChip(
                            label: 'مدير نظام',
                            role: AdminPermissions.admin,
                            icon: Icons.admin_panel_settings_rounded,
                          ),
                          _buildRoleChoiceChip(
                            label: 'دعم فني (قراءة)',
                            role: AdminPermissions.support,
                            icon: Icons.support_agent_rounded,
                          ),
                          _buildRoleChoiceChip(
                            label: 'صلاحيات مخصصة',
                            role: 'custom',
                            icon: Icons.tune_rounded,
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      TextWidget(
                        'الصلاحيات الممنوحة:',
                        style: TextStyles.font14WeightBoldText(),
                      ),
                      SizedBox(height: 8.h),
                      if (_selectedRole == AdminPermissions.superAdmin)
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFD4AF37,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: const Color(0xFFD4AF37),
                                size: 22.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextWidget(
                                  'يمتلك السوبر أدمن صلاحية كاملة وغير مقيدة على جميع أجزاء النظام (*).',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF8C6D00),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._availablePermissions.map((perm) {
                          final key = perm['key']!;
                          final isChecked =
                              _selectedPermissions.contains(key) ||
                              _selectedPermissions.contains('*');
                          return CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: TextWidget(
                              perm['label']!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textColor,
                              ),
                            ),
                            subtitle: TextWidget(
                              perm['desc']!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.subTitleColor,
                              ),
                            ),
                            value: isChecked,
                            onChanged: (val) {
                              setState(() {
                                _selectedRole = 'custom';
                                if (val == true) {
                                  _selectedPermissions.remove('*');
                                  _selectedPermissions.add(key);
                                } else {
                                  _selectedPermissions.remove(key);
                                  _selectedPermissions.remove('*');
                                }
                              });
                            },
                          );
                        }),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: TextWidget('cancel'.tr()),
                  ),
                  SizedBox(width: 10.w),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        Navigator.pop(context);
                        final perms =
                            _selectedRole == AdminPermissions.superAdmin
                            ? ['*']
                            : _selectedPermissions.toList();
                        widget.onAdd(
                          _nameCtrl.text.trim(),
                          _emailCtrl.text.trim().toLowerCase(),
                          _passwordCtrl.text.trim(),
                          _selectedRole,
                          perms,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                    ),
                    child: TextWidget(
                      'إنشاء وتفعيل الحساب',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChoiceChip({
    required String label,
    required String role,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: isSelected ? Colors.white : AppColors.primaryColor,
          ),
          SizedBox(width: 6.w),
          Text(label),
        ],
      ),
      selected: isSelected,
      selectedColor: AppColors.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12.sp,
      ),
      onSelected: (_) => _onRoleChanged(role),
    );
  }
}

// ─── Edit Admin Dialog ───────────────────────────────────────────────────────

class _EditAdminDialog extends StatefulWidget {
  final DashboardAdmin admin;
  final void Function(String name, String role, List<String> permissions)
  onUpdate;

  const _EditAdminDialog({required this.admin, required this.onUpdate});

  @override
  State<_EditAdminDialog> createState() => _EditAdminDialogState();
}

class _EditAdminDialogState extends State<_EditAdminDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;

  late String _selectedRole;
  late Set<String> _selectedPermissions;

  static const _availablePermissions = [
    {
      'key': AdminPermissions.usersRead,
      'label': 'استعراض المستخدمين',
      'desc': 'قراءة تفاصيل وبيانات العملاء',
    },
    {
      'key': AdminPermissions.usersWrite,
      'label': 'إدارة المستخدمين',
      'desc': 'إنشاء وتعديل وحذف المستخدمين والاشتراكات',
    },
    {
      'key': AdminPermissions.subscriptionsRead,
      'label': 'استعراض الاشتراكات',
      'desc': 'متابعة الاشتراكات والمنتهية',
    },
    {
      'key': AdminPermissions.subscriptionsWrite,
      'label': 'إدارة الاشتراكات',
      'desc': 'تجديد وتمديد وإيقاف الاشتراكات',
    },
    {
      'key': AdminPermissions.notificationsRead,
      'label': 'استعراض الإشعارات',
      'desc': 'قراءة سجل الإشعارات',
    },
    {
      'key': AdminPermissions.notificationsWrite,
      'label': 'إرسال الإشعارات',
      'desc': 'بث إشعارات عامة لجميع المستخدمين',
    },
    {
      'key': AdminPermissions.auditRead,
      'label': 'سجل النشاط والرقابة',
      'desc': 'مراقبة العمليات والإجراءات الإدارية',
    },
    {
      'key': AdminPermissions.settingsRead,
      'label': 'قراءة إعدادات النظام',
      'desc': 'استعراض إعدادات وإصدارات التطبيق',
    },
    {
      'key': AdminPermissions.settingsWrite,
      'label': 'تعديل إعدادات النظام',
      'desc': 'تحديث بيانات الإصدار وروابط التنزيل',
    },
    {
      'key': AdminPermissions.adminsWrite,
      'label': 'إدارة المدراء',
      'desc': 'إضافة وتعديل وحذف مدراء الداشبورد',
    },
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.admin.name);
    _selectedRole = widget.admin.role;
    _selectedPermissions = Set<String>.from(widget.admin.permissions);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _onRoleChanged(String role) {
    setState(() {
      _selectedRole = role;
      if (role == AdminPermissions.superAdmin) {
        _selectedPermissions = {'*'};
      } else if (role == AdminPermissions.admin) {
        _selectedPermissions = {
          AdminPermissions.usersRead,
          AdminPermissions.usersWrite,
          AdminPermissions.subscriptionsRead,
          AdminPermissions.subscriptionsWrite,
          AdminPermissions.notificationsRead,
          AdminPermissions.notificationsWrite,
          AdminPermissions.auditRead,
          AdminPermissions.settingsRead,
        };
      } else if (role == AdminPermissions.support) {
        _selectedPermissions = {
          AdminPermissions.usersRead,
          AdminPermissions.subscriptionsRead,
          AdminPermissions.notificationsRead,
          AdminPermissions.auditRead,
        };
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.admin.isPrimarySuperAdmin;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        width: 600.w,
        constraints: BoxConstraints(maxHeight: 700.h),
        padding: EdgeInsets.all(20.r),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.manage_accounts_rounded,
                      color: AppColors.primaryColor,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: TextWidget(
                      'admins_edit_admin'.tr(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        'البريد الإلكتروني',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      TextFormField(
                        initialValue: widget.admin.email,
                        enabled: false,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          filled: true,
                          fillColor: AppColors.subTitleColor.withValues(
                            alpha: 0.08,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextWidget(
                        'الاسم الكامل',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'يرجى إدخال الاسم'
                            : null,
                      ),
                      SizedBox(height: 16.h),
                      if (isPrimary) ...[
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFD4AF37,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                color: const Color(0xFFD4AF37),
                                size: 22.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextWidget(
                                  'هذا هو الحساب المالك الأساسي للنظام، يملك صلاحية السوبر أدمن الكاملة دائماً ولا يمكن تقييدها.',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF7A5C00),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        TextWidget(
                          'نوع الدور والصلاحيات',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: [
                            _buildRoleChoiceChip(
                              label: 'سوبر أدمن (شامل)',
                              role: AdminPermissions.superAdmin,
                              icon: Icons.workspace_premium_rounded,
                            ),
                            _buildRoleChoiceChip(
                              label: 'مدير نظام',
                              role: AdminPermissions.admin,
                              icon: Icons.admin_panel_settings_rounded,
                            ),
                            _buildRoleChoiceChip(
                              label: 'دعم فني (قراءة)',
                              role: AdminPermissions.support,
                              icon: Icons.support_agent_rounded,
                            ),
                            _buildRoleChoiceChip(
                              label: 'صلاحيات مخصصة',
                              role: 'custom',
                              icon: Icons.tune_rounded,
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        TextWidget(
                          'الصلاحيات الممنوحة:',
                          style: TextStyles.font14WeightBoldText(),
                        ),
                        SizedBox(height: 8.h),
                        if (_selectedRole == AdminPermissions.superAdmin)
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFD4AF37,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: const Color(0xFFD4AF37),
                                  size: 22.sp,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: TextWidget(
                                    'يمتلك السوبر أدمن صلاحية كاملة وغير مقيدة على جميع أجزاء النظام (*).',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF8C6D00),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ..._availablePermissions.map((perm) {
                            final key = perm['key']!;
                            final isChecked =
                                _selectedPermissions.contains(key) ||
                                _selectedPermissions.contains('*');
                            return CheckboxListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: TextWidget(
                                perm['label']!,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColor,
                                ),
                              ),
                              subtitle: TextWidget(
                                perm['desc']!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.subTitleColor,
                                ),
                              ),
                              value: isChecked,
                              onChanged: (val) {
                                setState(() {
                                  _selectedRole = 'custom';
                                  if (val == true) {
                                    _selectedPermissions.remove('*');
                                    _selectedPermissions.add(key);
                                  } else {
                                    _selectedPermissions.remove(key);
                                    _selectedPermissions.remove('*');
                                  }
                                });
                              },
                            );
                          }),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: TextWidget('cancel'.tr()),
                  ),
                  SizedBox(width: 10.w),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        Navigator.pop(context);
                        final perms = isPrimary
                            ? ['*']
                            : (_selectedRole == AdminPermissions.superAdmin
                                  ? ['*']
                                  : _selectedPermissions.toList());
                        widget.onUpdate(
                          _nameCtrl.text.trim(),
                          isPrimary
                              ? AdminPermissions.superAdmin
                              : _selectedRole,
                          perms,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                    ),
                    child: TextWidget(
                      'حفظ التعديلات',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChoiceChip({
    required String label,
    required String role,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: isSelected ? Colors.white : AppColors.primaryColor,
          ),
          SizedBox(width: 6.w),
          Text(label),
        ],
      ),
      selected: isSelected,
      selectedColor: AppColors.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12.sp,
      ),
      onSelected: (_) => _onRoleChanged(role),
    );
  }
}
