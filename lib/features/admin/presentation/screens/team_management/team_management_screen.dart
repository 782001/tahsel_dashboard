import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/constants/app_rbac_catalog.dart';
import 'package:tahsel_dashboard/core/extensions/auth_context_extensions.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/core/services/injection_container.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
import 'package:tahsel_dashboard/core/utils/styles.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/tenant_employee.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/team_management/team_management_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/team_management/team_management_state.dart';
import 'package:tahsel_dashboard/shared/widgets/custom_app_bar/custom_app_bar.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';
import 'package:tahsel_dashboard/shared/widgets/toast/custom_toast.dart';
import 'add_app_employee_screen.dart';
import 'edit_app_employee_screen.dart';

class TeamManagementScreen extends StatefulWidget {
  final String ownerUid;
  final String ownerName;
  final String? ownerUserType;

  const TeamManagementScreen({
    super.key,
    required this.ownerUid,
    required this.ownerName,
    this.ownerUserType,
  });

  static Future<void> push(
    BuildContext context, {
    required String ownerUid,
    required String ownerName,
    String? ownerUserType,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeamManagementScreen(
          ownerUid: ownerUid,
          ownerName: ownerName,
          ownerUserType: ownerUserType,
        ),
      ),
    );
  }

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  late final TeamManagementCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<TeamManagementCubit>();
    _cubit.loadEmployees(widget.ownerUid);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _showDeleteConfirmation(String employeeId, String employeeName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 26.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: TextWidget(
                'حذف حساب الموظف',
                style: TextStyles.font16WeightBoldText(),
              ),
            ),
          ],
        ),
        content: TextWidget(
          'هل أنت متأكد من رغبتك في حذف صلاحية وحساب هذا الموظف؟\n\nاسم الموظف: $employeeName',
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
              _cubit.deleteEmployee(
                ownerUid: widget.ownerUid,
                employeeId: employeeId,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: TextWidget(
              'admin_delete_user'.tr(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!context.canReadUsers) {
      return Scaffold(
        backgroundColor: AppColors.scafoldBackGround,
        appBar: CustomAppBar(
          centerTitle: 'فريق العمل والصلاحيات',
          leadingIcon: const Icon(Icons.arrow_back_ios_new_rounded),
          onLeadingTap: () => Navigator.pop(context),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 48.sp, color: AppColors.error),
                SizedBox(height: 12.h),
                TextWidget(
                  'غير مصرح لك باستعراض فريق العمل',
                  style: TextStyles.font16WeightBoldText(),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const TextWidget('رجوع'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.scafoldBackGround,
        appBar: CustomAppBar(
          centerTitle: 'فريق العمل والصلاحيات',
          leadingIcon: const Icon(Icons.arrow_back_ios_new_rounded),
          onLeadingTap: () => Navigator.pop(context),
          actionIcon: Padding(
            padding: EdgeInsetsDirectional.only(end: 14.w),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.vipGoldStart, AppColors.vipGoldEnd],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.vipGoldStart.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      size: 14,
                      color: Colors.black87,
                    ),
                    SizedBox(width: 3.w),
                    const Text(
                      'VIP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: context.canWriteUsers
            ? FloatingActionButton.extended(
                onPressed: () => AddAppEmployeeScreen.push(
                  context,
                  ownerUid: widget.ownerUid,
                  cubit: _cubit,
                  userType: widget.ownerUserType,
                ),
                backgroundColor: AppColors.primaryColor,
                icon: const Icon(Icons.person_add_rounded, color: Colors.white),
                label: const Text(
                  'إضافة موظف جديد',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            : null,
        body: SafeArea(
          child: BlocConsumer<TeamManagementCubit, TeamManagementState>(
            listener: (context, state) {
              if (state is TeamManagementActionSuccess) {
                showSuccessToast(state.message);
              } else if (state is TeamManagementFailure) {
                showfailureToast(state.message);
              }
            },
            builder: (context, state) {
              if (state is TeamManagementLoading && _cubit.employees.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    color: AppColors.primaryColor,
                  ),
                );
              }

              final employees = _cubit.employees;

              return RefreshIndicator(
                onRefresh: () => _cubit.loadEmployees(widget.ownerUid),
                color: AppColors.primaryColor,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1000 : double.infinity,
                    ),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 24 : 16.w,
                        vertical: 16.h,
                      ),
                      children: [
                        _buildOverviewCard(context, employees),
                        SizedBox(height: 18.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextWidget(
                              'الموظفون المسجلون (${employees.length})',
                              style: TextStyles.font16WeightBoldText(),
                            ),
                            if (widget.ownerName.isNotEmpty) ...[
                              SizedBox(width: 8.w),
                              Flexible(
                                child: TextWidget(
                                  'المنشأة: ${widget.ownerName}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.subTitleColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 12.h),
                        if (employees.isEmpty)
                          _buildEmptyState(context)
                        else
                          ...employees.map(
                            (emp) => _buildEmployeeCard(context, emp),
                          ),
                        SizedBox(height: 80.h),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, List<TenantEmployee> employees) {
    final activeCount = employees.where((e) => e.isActive).length;
    final disabledCount = employees.length - activeCount;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 15.w,
            bottom: -15.h,
            child: Icon(
              Icons.admin_panel_settings_outlined,
              size: 90.sp,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.vipGoldStart.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: AppColors.vipGoldStart,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'فريق العمل والصلاحيات',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'إدارة حسابات الموظفين والصلاحيات الممنوحة لهم في التطبيق',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.vipGoldStart, AppColors.vipGoldEnd],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.vipGoldStart.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            size: 13,
                            color: Colors.black87,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'VIP',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('إجمالي الموظفين', employees.length.toString()),
                    Container(height: 25.h, width: 1, color: Colors.white24),
                    _buildStatColumn('نشط في الخدمة', activeCount.toString()),
                    Container(height: 25.h, width: 1, color: Colors.white24),
                    _buildStatColumn('معطل مؤقتاً', disabledCount.toString()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGreyColor),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.group_off_outlined,
              size: 56.sp,
              color: AppColors.subTitleColor.withValues(alpha: 0.5),
            ),
            SizedBox(height: 14.h),
            TextWidget(
              'admin_no_employees_yet'.tr(),
              style: TextStyles.font16WeightBoldText().copyWith(
                color: AppColors.subTitleColor,
              ),
            ),
            SizedBox(height: 8.h),
            TextWidget(
              'يمكنك إضافة أول موظف لهذه المنشأة وتحديد دوره وصلاحياته',
              style: TextStyle(fontSize: 12.sp, color: AppColors.subTitleColor),
            ),
            SizedBox(height: 18.h),
            ElevatedButton.icon(
              onPressed: () => AddAppEmployeeScreen.push(
                context,
                ownerUid: widget.ownerUid,
                cubit: _cubit,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 18),
              label: const Text(
                'إضافة موظف جديد',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(BuildContext context, TenantEmployee emp) {
    final bool isActive = emp.isActive;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isActive
              ? AppColors.lightGreyColor
              : AppColors.error.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: isActive
                      ? AppColors.primaryColor.withValues(alpha: 0.1)
                      : AppColors.disabledColor.withValues(alpha: 0.2),
                  child: Text(
                    emp.name.isNotEmpty ? emp.name[0].toUpperCase() : '؟',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppColors.primaryColor : AppColors.subTitleColor,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emp.name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        emp.email,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.subTitleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: isActive,
                    activeThumbColor: AppColors.success,
                    onChanged: (_) {
                      _cubit.toggleStatus(
                        ownerUid: widget.ownerUid,
                        employeeId: emp.id,
                        currentStatus: emp.accountStatus,
                      );
                    },
                  ),
                ),
              ],
            ),
            Divider(height: 18.h, color: AppColors.lightGreyColor),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildRoleBadge(emp.rolePreset),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.scafoldBackGround,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.lightGreyColor),
                        ),
                        child: Text(
                          '${emp.permissions.contains('*') ? AppRbacCatalog.totalPermissions : emp.permissions.length} ${'admin_permissions_count'.tr()}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.subTitleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (context.canWriteUsers) ...[
                  SizedBox(width: 4.w),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        color: AppColors.primaryColor,
                        tooltip: 'تعديل بيانات وصلاحيات الموظف',
                        onPressed: () {
                          EditAppEmployeeScreen.push(
                            context,
                            ownerUid: widget.ownerUid,
                            employee: emp,
                            cubit: _cubit,
                            userType: widget.ownerUserType,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 20),
                        color: AppColors.error,
                        tooltip: 'حذف الموظف',
                        onPressed: () => _showDeleteConfirmation(emp.id, emp.name),
                      ),
                    ],
                  ),
                ],

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String preset) {
    String label = AppRbacCatalog.getRoleLabel(preset);
    Color color = AppColors.primaryColor;

    switch (preset) {
      case AppRbacCatalog.roleCashier:
        color = Colors.blue;
        break;
      case AppRbacCatalog.roleStorekeeper:
        color = Colors.orange;
        break;
      case AppRbacCatalog.roleAccountant:
        color = Colors.teal;
        break;
      case AppRbacCatalog.roleSupervisor:
        color = Colors.purple;
        break;
      case AppRbacCatalog.roleCustom:
        color = AppColors.primaryColor;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
