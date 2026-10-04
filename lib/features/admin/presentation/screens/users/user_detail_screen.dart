import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tahsel_dashboard/core/constants/admin_constants.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/core/services/currency/data/world_currencies.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
import 'package:tahsel_dashboard/core/utils/app_logger.dart';
import 'package:tahsel_dashboard/core/utils/app_strings.dart';
import 'package:tahsel_dashboard/core/utils/styles.dart';
import 'package:tahsel_dashboard/features/admin/domain/usecases/admin_usecases.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/user_detail/user_detail_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/user_detail/user_detail_state.dart';
import 'package:tahsel_dashboard/features/admin/presentation/widgets/copy_uid_button.dart';
import 'package:tahsel_dashboard/features/admin/presentation/widgets/custom_days_dialog.dart';
import 'package:tahsel_dashboard/features/admin/presentation/widgets/status_badge.dart';
import 'package:tahsel_dashboard/shared/widgets/buttons/custom_button.dart';
import 'package:tahsel_dashboard/shared/widgets/custom_app_bar/custom_app_bar.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';
import 'package:tahsel_dashboard/shared/widgets/toast/custom_toast.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/app_user.dart';
import 'package:tahsel_dashboard/features/admin/presentation/screens/users/edit_user_screen.dart';
import 'package:tahsel_dashboard/features/admin/presentation/screens/team_management/team_management_screen.dart';
import 'package:tahsel_dashboard/routes/app_routes.dart';

class UserDetailScreen extends StatefulWidget {
  final String uid;
  const UserDetailScreen({super.key, required this.uid});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserDetailCubit>().load(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scafoldBackGround,
      appBar: CustomAppBar(
        centerTitle: 'admin_user_details'.tr(),
        leadingIcon: const Icon(Icons.arrow_back_ios_new_rounded),
        onLeadingTap: () => Navigator.pop(context),
      ),
      body: BlocBuilder<UserDetailCubit, UserDetailState>(
        builder: (context, state) {
          if (state is UserDetailLoading || state is UserDetailActionLoading) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.w,
                color: AppColors.primaryColor,
              ),
            );
          }
          if (state is UserDetailError) {
            AppLogger.printMessage(
              'Error loading user details: ${state.message}',
            );
            return Center(child: TextWidget(state.message));
          }
          if (state is UserDetailLoaded) {
            final user = state.user;
            final df = DateFormat.yMMMd();
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section('admin_profile'.tr(), [
                    Row(
                      children: [
                        Expanded(
                          child: TextWidget(
                            user.fullName,
                            style: TextStyles.appbartext().copyWith(
                              fontSize: 22.sp,
                            ),
                          ),
                        ),
                        if (user.isVip) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFFD700,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.workspace_premium_rounded,
                                  size: 15,
                                  color: Colors.black87,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'VIP',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                        ],
                        StatusBadge(
                          statusKey: user.accountStatus,
                          isEmployee: user.isEmployee,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    _infoRow(
                      'admin_uid'.tr(),
                      user.uid,
                      trailing: CopyButton(text: user.uid),
                    ),
                    _infoRow(
                      'admin_current_status'.tr(),
                      (user.isEmployee && user.accountStatus == 'expired')
                          ? 'status_disabled'.tr()
                          : 'status_${user.accountStatus}'.tr(),
                    ),
                    _infoRow(
                      'email_address'.tr(),
                      user.email,
                      trailing: CopyButton(
                        text: user.email,
                        tostText: 'email_copied',
                      ),
                    ),
                    _infoRow(
                      'customer_phone'.tr(),
                      user.phoneNumber.isEmpty
                          ? 'admin_not_found'.tr()
                          : user.phoneNumber,
                      trailing: CopyButton(
                        text: user.phoneNumber,
                        tostText: 'phone_copied',
                      ),
                    ),
                    _infoRow(
                      'admin_user_type'.tr(),
                      user.userType == 'shop'
                          ? 'user_type_shop'.tr()
                          : 'user_type_cafe'.tr(),
                    ),
                    _infoRow(
                      'admin_platform_type'.tr(),
                      user.platformType == 'desktop'
                          ? 'platform_type_desktop'.tr()
                          : user.platformType == 'both'
                          ? 'platform_type_both'.tr()
                          : 'platform_type_mobile'.tr(),
                    ),
                    _infoRow(
                      'VIP Account',
                      user.isVip ? '☑ Enabled (VIP)' : '☐ Disabled (Standard)',
                    ),
                    _infoRow(
                      'admin_role'.tr(),
                      user.isEmployee
                          ? 'role_employee'.tr()
                          : 'role_owner'.tr(),
                    ),
                    if (user.crn != null && user.crn!.isNotEmpty)
                      _infoRow('admin_crn'.tr(), user.crn!),
                    if (user.vat != null && user.vat!.isNotEmpty)
                      _infoRow('admin_vat'.tr(), user.vat!),
                    if (user.taxRate != null)
                      _infoRow('admin_tax_rate'.tr(), '${user.taxRate}%'),
                    if (user.address != null && user.address!.isNotEmpty)
                      _infoRow('admin_address'.tr(), user.address!),
                    if (user.currency != null && user.currency!.isNotEmpty) ...[
                      () {
                        final c = WorldCurrencies.findByCode(user.currency!);
                        return _infoRow(
                          AppStrings.currencyLabel.tr(),
                          '${c.getName(AppStrings.currentLang)} (${c.getSymbol(AppStrings.currentLang)} - ${c.code})',
                        );
                      }(),
                    ],
                    _infoRow(
                      'admin_created'.tr(),
                      user.createdAt != null ? df.format(user.createdAt!) : '-',
                    ),
                    _infoRow(
                      'admin_last_login'.tr(),
                      user.lastLogin != null ? df.format(user.lastLogin!) : '-',
                    ),
                    _infoRow(
                      'admin_last_active'.tr(),
                      user.lastActive != null
                          ? df.format(user.lastActive!)
                          : '-',
                    ),
                    if (user.devicePlatform != null)
                      _infoRow(
                        'admin_device_platform'.tr(),
                        user.devicePlatform!,
                      ),
                  ]),
                  if (!user.isEmployee)
                    _section('admin_subscription'.tr(), [
                    Row(
                      children: [
                        StatusBadge(statusKey: user.subscriptionStatus),
                        SizedBox(width: 8.w),
                        TextWidget(
                          '${'admin_days_remaining'.tr()}: ${user.daysRemaining}',
                        ),
                      ],
                    ),
                    _infoRow(
                      'admin_sub_start'.tr(),
                      user.subscriptionStart != null
                          ? df.format(user.subscriptionStart!)
                          : '-',
                    ),
                    _infoRow(
                      'admin_sub_end'.tr(),
                      user.subscriptionEnd != null
                          ? df.format(user.subscriptionEnd!)
                          : '-',
                    ),
                    _infoRow(
                      'admin_grace_period_end'.tr(),
                      user.gracePeriodEnd != null
                          ? df.format(user.gracePeriodEnd!)
                          : '-',
                    ),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        for (final days in AdminConstants.subscriptionPresets)
                          OutlinedButton(
                            onPressed: () =>
                                _subscription(SubscriptionAction.renew, days),
                            child: TextWidget('${'admin_renew'.tr()} $days'),
                          ),
                        OutlinedButton(
                          onPressed: () =>
                              _subscription(SubscriptionAction.extend, 30),
                          child: TextWidget('admin_extend'.tr()),
                        ),
                        OutlinedButton(
                          onPressed: () => _shortenSubscription(),
                          child: TextWidget('admin_shorten'.tr()),
                        ),
                        OutlinedButton(
                          onPressed: () =>
                              _subscription(SubscriptionAction.suspend, 0),
                          child: TextWidget('admin_suspend_sub'.tr()),
                        ),
                        OutlinedButton(
                          onPressed: () =>
                              _subscription(SubscriptionAction.reactivate, 0),
                          child: TextWidget('admin_reactivate_sub'.tr()),
                        ),
                        OutlinedButton(
                          onPressed: () => _customSubscription(),
                          child: TextWidget('admin_custom_duration'.tr()),
                        ),
                      ],
                    ),
                  ]),
                  _section('admin_usage_stats'.tr(), [_statsGrid(user)]),
                  if (user.isEmployee)
                    _section('admin_team_members'.tr(), [
                      Builder(
                        builder: (context) {
                          final employeeColor = AppColors.isDark
                              ? const Color(0xFFB39DDB)
                              : const Color(0xFF673AB7);
                          return Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: employeeColor.withValues(
                                alpha: AppColors.isDark ? 0.12 : 0.08,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: employeeColor.withValues(
                                  alpha: AppColors.isDark ? 0.35 : 0.25,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: employeeColor.withValues(
                                      alpha: AppColors.isDark ? 0.2 : 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(
                                    Icons.badge_outlined,
                                    color: employeeColor,
                                    size: 26.sp,
                                  ),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextWidget(
                                        'حساب موظف (تابع لمنشأة)',
                                        style: TextStyles.font16WeightBoldText()
                                            .copyWith(color: employeeColor),
                                      ),
                                      SizedBox(height: 6.h),
                                      TextWidget(
                                        'هذا الحساب مسجل كموظف ضمن فريق العمل، ولا يمكن إضافة موظفين لحساب موظف. ميزة إدارة وإضافة الموظفين متاحة لحسابات المالك فقط.',
                                        style:
                                            TextStyles.font14Weight400RightAligned()
                                                .copyWith(
                                                  color:
                                                      AppColors.subTitleColor,
                                                ),
                                      ),
                                      if (user.ownerUid != null &&
                                          user.ownerUid!.isNotEmpty) ...[
                                        SizedBox(height: 12.h),
                                        ElevatedButton.icon(
                                          onPressed: () => Navigator.pushNamed(
                                            context,
                                            AppRoutes.userDetail,
                                            arguments: user.ownerUid!,
                                          ),
                                          icon: const Icon(
                                            Icons.storefront_rounded,
                                            size: 16,
                                          ),
                                          label: TextWidget(
                                            'الانتقال لحساب المالك الرئيسي',
                                            style: TextStyles.customStyle(
                                              fontSize: 12,
                                              color: AppColors.white,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: employeeColor,
                                            foregroundColor: AppColors.isDark
                                                ? Colors.black87
                                                : Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ])
                  else
                    _section(
                      'admin_team_members'.tr(),
                      [
                        if (state.employees.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.group_outlined,
                                    size: 40.sp,
                                    color: AppColors.subTitleColor.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  TextWidget(
                                    'admin_no_employees_yet'.tr(),
                                    style:
                                        TextStyles.font14Weight400RightAligned()
                                            .copyWith(
                                              color: AppColors.subTitleColor,
                                            ),
                                  ),
                                  SizedBox(height: 12.h),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      await TeamManagementScreen.push(
                                        context,
                                        ownerUid: widget.uid,
                                        ownerName: user.fullName,
                                        ownerUserType: user.userType,
                                      );
                                      if (context.mounted) {
                                        context.read<UserDetailCubit>().load(
                                          widget.uid,
                                        );
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.group_add_rounded,
                                      size: 18,
                                    ),
                                    label: const TextWidget(
                                      'إدارة وإضافة أعضاء الفريق',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 10.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...state.employees.map(
                            (emp) => InkWell(
                              borderRadius: BorderRadius.circular(10.r),
                              onTap: () async {
                                await TeamManagementScreen.push(
                                  context,
                                  ownerUid: widget.uid,
                                  ownerName: user.fullName,
                                  ownerUserType: user.userType,
                                );
                                if (context.mounted) {
                                  context.read<UserDetailCubit>().load(
                                    widget.uid,
                                  );
                                }
                              },
                              child: Card(
                                margin: EdgeInsets.only(bottom: 8.h),
                                color: AppColors.scafoldBackGround,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  side: BorderSide(
                                    color: AppColors.primaryColor.withValues(
                                      alpha: 0.15,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(12.w),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18.r,
                                        backgroundColor: AppColors.primaryColor
                                            .withValues(alpha: 0.1),
                                        child: Text(
                                          emp.name.isNotEmpty
                                              ? emp.name[0].toUpperCase()
                                              : '؟',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryColor,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              spacing: 8.w,
                                              runSpacing: 4.h,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                TextWidget(
                                                  emp.name,
                                                  style:
                                                      TextStyles.font14Weight400RightAligned()
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8.w,
                                                    vertical: 2.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors
                                                        .primaryColor
                                                        .withValues(
                                                          alpha: 0.12,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6.r,
                                                        ),
                                                  ),
                                                  child: TextWidget(
                                                    emp.rolePreset,
                                                    style: TextStyle(
                                                      fontSize: 11.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                ),
                                                StatusBadge(
                                                  statusKey: emp.accountStatus,
                                                  isEmployee: true,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4.h),
                                            TextWidget(
                                              emp.email,
                                              style:
                                                  TextStyles.font14Weight400RightAligned()
                                                      .copyWith(
                                                        color: AppColors
                                                            .subTitleColor,
                                                        fontSize: 12.sp,
                                                      ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14.sp,
                                        color: AppColors.subTitleColor
                                            .withValues(alpha: 0.6),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                      trailing: ElevatedButton.icon(
                        onPressed: () async {
                          await TeamManagementScreen.push(
                            context,
                            ownerUid: widget.uid,
                            ownerName: user.fullName,
                            ownerUserType: user.userType,
                          );
                          if (context.mounted) {
                            context.read<UserDetailCubit>().load(widget.uid);
                          }
                        },
                        icon: const Icon(Icons.group_rounded, size: 18),
                        label: TextWidget(
                          'إدارة فريق العمل',
                          style: TextStyles.customStyle(
                            fontSize: 12,
                            color: AppColors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                  // _section('admin_sessions'.tr(), [
                  //   if (state.sessions.isEmpty)
                  //     TextWidget('no_data'.tr())
                  //   else
                  //     ...state.sessions.map(
                  //       (s) => ListTile(
                  //         title: TextWidget(s.platform),
                  //         subtitle: TextWidget(
                  //           s.lastActive != null
                  //               ? df.format(s.lastActive!)
                  //               : '-',
                  //         ),
                  //         trailing: s.active
                  //             ? Icon(
                  //                 Icons.circle,
                  //                 color: AppColors.success,
                  //                 size: 10.sp,
                  //               )
                  //             : null,
                  //       ),
                  //     ),
                  //   CustomButton(
                  //     text: 'admin_force_logout'.tr(),
                  //     width: 200.w,
                  //     onPressed: () async {
                  //       final cubit = context.read<UserDetailCubit>();
                  //       final ok = await cubit.forceLogout();
                  //       if (!mounted) return;
                  //       if (ok) {
                  //         showSuccessToast('admin_force_logout_success'.tr());
                  //       }
                  //     },
                  //   ),
                  // ]),
                  _section('admin_notes'.tr(), [
                    ...state.notes.map(
                      (n) => Card(
                        child: ListTile(
                          title: TextWidget(n.content),
                          subtitle: TextWidget(
                            '${n.adminName} • ${n.createdAt != null ? df.format(n.createdAt!) : ''}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _editNote(n.id, n.content),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => context
                                    .read<UserDetailCubit>()
                                    .deleteNote(n.id),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _addNote(),
                      icon: const Icon(Icons.add),
                      label: TextWidget('admin_add_note'.tr()),
                    ),
                  ]),
                  if (!user.isEmployee)
                    _section('admin_actions'.tr(), [
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        CustomButton(
                          text: 'admin_edit_user'.tr(),
                          width: 160.w,
                          onPressed: () => _editUser(user),
                        ),
                        CustomButton(
                          text: 'admin_reset_password'.tr(),
                          width: 180.w,
                          onPressed: () => _resetPassword(),
                        ),
                        if (user.isActive)
                          CustomButton(
                            text: 'admin_suspend_user'.tr(),
                            width: 180.w,
                            color: AppColors.warning,
                            onPressed: () => _confirmAction(
                              'admin_suspend_user'.tr(),
                              'admin_confirm_suspend'.tr(),
                              () =>
                                  context.read<UserDetailCubit>().suspendUser(),
                              successKey: 'admin_user_suspended',
                            ),
                          ),
                        if (user.isSuspended)
                          CustomButton(
                            text: 'admin_activate_user'.tr(),
                            width: 180.w,
                            color: AppColors.success,
                            onPressed: () => _confirmAction(
                              'admin_activate_user'.tr(),
                              'admin_confirm_activate'.tr(),
                              () => context
                                  .read<UserDetailCubit>()
                                  .activateUser(),
                              successKey: 'admin_user_activated',
                            ),
                          ),
                        if (!user.isDeleted && !user.isDisabled)
                          CustomButton(
                            text: 'admin_disable_user'.tr(),
                            width: 180.w,
                            color: AppColors.error,
                            onPressed: () => _confirmAction(
                              'admin_disable_user'.tr(),
                              'admin_confirm_disable'.tr(),
                              () =>
                                  context.read<UserDetailCubit>().disableUser(),
                              successKey: 'admin_user_disabled',
                            ),
                          ),
                        if (user.isDisabled)
                          CustomButton(
                            text: 'admin_activate_user'.tr(),
                            width: 180.w,
                            color: AppColors.success,
                            onPressed: () => _confirmAction(
                              'admin_activate_user'.tr(),
                              'admin_confirm_activate'.tr(),
                              () => context
                                  .read<UserDetailCubit>()
                                  .activateUser(),
                              successKey: 'admin_user_activated',
                            ),
                          ),
                        if (!user.isDeleted)
                          CustomButton(
                            text: 'admin_delete_user'.tr(),
                            width: 180.w,
                            color: AppColors.error,
                            onPressed: () => _confirmDelete(),
                          ),
                      ],
                    ),
                  ]),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _section(String title, List<Widget> children, {Widget? trailing}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextWidget(
                  title,
                  style: TextStyles.font18Weight500Action(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) ...[SizedBox(width: 8.w), trailing],
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          SizedBox(
            width: 120.w,
            child: TextWidget(
              label,
              style: TextStyles.font14Weight400RightAligned().copyWith(
                color: AppColors.subTitleColor,
              ),
            ),
          ),
          Expanded(
            child: TextWidget(
              value,
              style: TextStyles.font14Weight400RightAligned(),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _statsGrid(dynamic user) {
    final stats = [
      ('admin_stat_customers'.tr(), user.stats.customers),
      ('admin_stat_debts'.tr(), user.stats.debts),
      ('employees'.tr(), user.stats.employees),
      ('transaction_count'.tr(), user.stats.transactions),
      ('expenses'.tr(), user.stats.expenses),
    ];
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: stats
          .map(
            (s) => SizedBox(
              width: 140.w,
              child: Column(
                children: [
                  TextWidget(
                    '${s.$2}',
                    style: TextStyles.font18Weight500Action(),
                  ),
                  TextWidget(
                    s.$1,
                    style: TextStyles.font14Weight400RightAligned(),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Future<void> _subscription(SubscriptionAction action, int days) async {
    final cubit = context.read<UserDetailCubit>();
    final ok = await cubit.subscriptionAction(
      SubscriptionParams(uid: widget.uid, action: action, days: days),
    );
    if (!mounted) return;
    if (ok) {
      showSuccessToast('admin_subscription_updated'.tr());
    }
  }

  Future<void> _shortenSubscription() async {
    final days = await showCustomDaysDialog(context, titleKey: 'admin_shorten');
    if (days == null || !mounted) return;
    await _subscription(SubscriptionAction.shorten, days);
  }

  Future<void> _customSubscription() async {
    final days = await showCustomDaysDialog(context);
    if (days == null || !mounted) return;
    await _subscription(SubscriptionAction.renew, days);
  }

  Future<void> _addNote() async {
    // Capture the cubit from the screen's context before opening the dialog
    final userDetailCubit = context.read<UserDetailCubit>();

    await showDialog(
      context: context,
      builder: (dialogContext) => _AddNoteDialog(cubit: userDetailCubit),
    );
  }

  Future<void> _editNote(String noteId, String current) async {
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: TextWidget('admin_edit_note'.tr()),
        content: TextField(controller: controller, maxLines: 3),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: TextWidget('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: TextWidget('confirm'.tr()),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && result.isNotEmpty && mounted) {
      await context.read<UserDetailCubit>().editNote(noteId, result);
    }
  }

  Future<void> _editUser(AppUser user) async {
    final updated = await EditUserScreen.push(context, user: user);
    if (updated == true && mounted) {
      context.read<UserDetailCubit>().load(widget.uid);
    }
  }

  Future<void> _resetPassword() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: TextWidget('admin_reset_password'.tr()),
        content: TextWidget('admin_reset_password_email_hint'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: TextWidget('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: TextWidget('confirm'.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final ok = await context.read<UserDetailCubit>().resetPassword('');
      if (ok && mounted) {
        showSuccessToast('admin_reset_email_sent'.tr());
      }
    }
  }

  Future<void> _confirmAction(
    String title,
    String message,
    Future<bool> Function() action, {
    required String successKey,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: TextWidget(title),
        content: TextWidget(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: TextWidget('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: TextWidget('confirm'.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final ok = await action();
      if (ok && mounted) {
        showSuccessToast(successKey.tr());
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: TextWidget('admin_delete_user'.tr()),
        content: TextWidget('admin_confirm_delete'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: TextWidget('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: TextWidget('confirm'.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final ok = await context.read<UserDetailCubit>().deleteUser();
      if (ok && mounted) {
        showSuccessToast('admin_user_deleted'.tr());
        Navigator.pop(context);
      }
    }
  }
}

// Create an isolated Stateful widget at the bottom of your file
class _AddNoteDialog extends StatefulWidget {
  final UserDetailCubit cubit;
  const _AddNoteDialog({required this.cubit});

  @override
  State<_AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<_AddNoteDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose(); // Safely managed by framework
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextWidget('admin_add_note'.tr()),
      content: TextField(controller: _controller, autofocus: true),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: TextWidget('cancel'.tr()),
        ),
        CustomButton(
          text: 'confirm'.tr(),
          width: 100.w,
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              // Note: Use the parent context to read the Cubit,
              // as dialogContext might not have the provider if it's not structural
              widget.cubit.addNote(_controller.text.trim());
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
