import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tahsel_dashboard/core/constants/admin_constants.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
import 'package:tahsel_dashboard/core/utils/styles.dart';
import 'package:tahsel_dashboard/features/admin/domain/usecases/admin_usecases.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/user_detail/user_detail_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/user_detail/user_detail_state.dart';
import 'package:tahsel_dashboard/features/admin/presentation/widgets/copy_uid_button.dart';
import 'package:tahsel_dashboard/features/admin/presentation/widgets/custom_days_dialog.dart';
import 'package:tahsel_dashboard/features/admin/presentation/widgets/status_badge.dart';
import 'package:tahsel_dashboard/shared/widgets/buttons/custom_button.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';
import 'package:tahsel_dashboard/shared/widgets/toast/custom_toast.dart';

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
      appBar: AppBar(
        title: TextWidget('admin_user_details'.tr()),
        backgroundColor: AppColors.surface,
      ),
      body: BlocBuilder<UserDetailCubit, UserDetailState>(
        builder: (context, state) {
          if (state is UserDetailLoading || state is UserDetailActionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UserDetailError) {
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
                            style: TextStyles.appbartext().copyWith(fontSize: 22.sp),
                          ),
                        ),
                        StatusBadge(statusKey: user.accountStatus),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    _infoRow('UID', user.uid, trailing: CopyUidButton(uid: user.uid)),
                    _infoRow('email_address'.tr(), user.email),
                    _infoRow('customer_phone'.tr(), user.phoneNumber),
                    _infoRow('admin_created'.tr(),
                        user.createdAt != null ? df.format(user.createdAt!) : '-'),
                    _infoRow('admin_last_login'.tr(),
                        user.lastLogin != null ? df.format(user.lastLogin!) : '-'),
                    _infoRow('admin_last_active'.tr(),
                        user.lastActive != null ? df.format(user.lastActive!) : '-'),
                    if (user.devicePlatform != null)
                      _infoRow('admin_device_platform'.tr(), user.devicePlatform!),
                  ]),
                  _section('admin_subscription'.tr(), [
                    Row(
                      children: [
                        StatusBadge(statusKey: user.subscriptionStatus),
                        SizedBox(width: 8.w),
                        TextWidget('${'admin_days_remaining'.tr()}: ${user.daysRemaining}'),
                      ],
                    ),
                    _infoRow('admin_sub_start'.tr(),
                        user.subscriptionStart != null ? df.format(user.subscriptionStart!) : '-'),
                    _infoRow('admin_sub_end'.tr(),
                        user.subscriptionEnd != null ? df.format(user.subscriptionEnd!) : '-'),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        for (final days in AdminConstants.subscriptionPresets)
                          OutlinedButton(
                            onPressed: () => _subscription(context, SubscriptionAction.renew, days),
                            child: Text('${'admin_renew'.tr()} $days'),
                          ),
                        OutlinedButton(
                          onPressed: () => _subscription(context, SubscriptionAction.extend, 30),
                          child: TextWidget('admin_extend'.tr()),
                        ),
                        OutlinedButton(
                          onPressed: () => _shortenSubscription(context),
                          child: TextWidget('admin_shorten'.tr()),
                        ),
                        OutlinedButton(
                          onPressed: () => _subscription(context, SubscriptionAction.suspend, 0),
                          child: TextWidget('admin_suspend_sub'.tr()),
                        ),
                        OutlinedButton(
                          onPressed: () => _subscription(context, SubscriptionAction.reactivate, 0),
                          child: TextWidget('admin_reactivate_sub'.tr()),
                        ),
                        OutlinedButton(
                          onPressed: () => _customSubscription(context),
                          child: TextWidget('admin_custom_duration'.tr()),
                        ),
                      ],
                    ),
                  ]),
                  _section('admin_usage_stats'.tr(), [
                    _statsGrid(user),
                  ]),
                  _section('admin_sessions'.tr(), [
                    if (state.sessions.isEmpty)
                      TextWidget('no_data'.tr())
                    else
                      ...state.sessions.map((s) => ListTile(
                            title: TextWidget(s.platform),
                            subtitle: TextWidget(s.lastActive != null
                                ? df.format(s.lastActive!)
                                : '-'),
                            trailing: s.active
                                ? Icon(Icons.circle, color: AppColors.success, size: 10.sp)
                                : null,
                          )),
                    CustomButton(
                      text: 'admin_force_logout'.tr(),
                      width: 200.w,
                      onPressed: () async {
                        final cubit = context.read<UserDetailCubit>();
                        final ok = await cubit.forceLogout();
                        if (!mounted) return;
                        if (ok) showSuccessToast('admin_force_logout_success'.tr());
                      },
                    ),
                  ]),
                  _section('admin_notes'.tr(), [
                    ...state.notes.map((n) => Card(
                          child: ListTile(
                            title: TextWidget(n.content),
                            subtitle: TextWidget(
                                '${n.adminName} • ${n.createdAt != null ? df.format(n.createdAt!) : ''}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _editNote(context, n.id, n.content),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () =>
                                      context.read<UserDetailCubit>().deleteNote(n.id),
                                ),
                              ],
                            ),
                          ),
                        )),
                    TextButton.icon(
                      onPressed: () => _addNote(context),
                      icon: const Icon(Icons.add),
                      label: TextWidget('admin_add_note'.tr()),
                    ),
                  ]),
                  _section('admin_actions'.tr(), [
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        CustomButton(
                          text: 'admin_edit_user'.tr(),
                          width: 160.w,
                          onPressed: () => _editUser(context, user),
                        ),
                        CustomButton(
                          text: 'admin_reset_password'.tr(),
                          width: 180.w,
                          onPressed: () => _resetPassword(context),
                        ),
                        if (user.isActive)
                          CustomButton(
                            text: 'admin_suspend_user'.tr(),
                            width: 180.w,
                            color: AppColors.warning,
                            onPressed: () => _confirmAction(
                              context,
                              'admin_suspend_user'.tr(),
                              'admin_confirm_suspend'.tr(),
                              () => context.read<UserDetailCubit>().suspendUser(),
                              successKey: 'admin_user_suspended',
                            ),
                          ),
                        if (user.isSuspended)
                          CustomButton(
                            text: 'admin_activate_user'.tr(),
                            width: 180.w,
                            color: AppColors.success,
                            onPressed: () => _confirmAction(
                              context,
                              'admin_activate_user'.tr(),
                              'admin_confirm_activate'.tr(),
                              () => context.read<UserDetailCubit>().activateUser(),
                              successKey: 'admin_user_activated',
                            ),
                          ),
                        if (!user.isDeleted)
                          CustomButton(
                            text: 'admin_delete_user'.tr(),
                            width: 180.w,
                            color: AppColors.error,
                            onPressed: () => _confirmDelete(context),
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

  Widget _section(String title, List<Widget> children) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(title, style: TextStyles.font18Weight500Action()),
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
            child: TextWidget(label, style: TextStyles.font14Weight400RightAligned().copyWith(
              color: AppColors.subTitleColor,
            )),
          ),
          Expanded(child: TextWidget(value, style: TextStyles.font14Weight400RightAligned())),
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
          .map((s) => SizedBox(
                width: 140.w,
                child: Column(
                  children: [
                    TextWidget('${s.$2}', style: TextStyles.font18Weight500Action()),
                    TextWidget(s.$1, style: TextStyles.font14Weight400RightAligned()),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Future<void> _subscription(
    BuildContext context,
    SubscriptionAction action,
    int days,
  ) async {
    final cubit = context.read<UserDetailCubit>();
    final ok = await cubit.subscriptionAction(
      SubscriptionParams(uid: widget.uid, action: action, days: days),
    );
    if (!mounted) return;
    if (ok) showSuccessToast('admin_subscription_updated'.tr());
  }

  Future<void> _shortenSubscription(BuildContext context) async {
    final days = await showCustomDaysDialog(context, titleKey: 'admin_shorten');
    if (days == null || !mounted) return;
    await _subscription(context, SubscriptionAction.shorten, days);
  }

  Future<void> _customSubscription(BuildContext context) async {
    final days = await showCustomDaysDialog(context);
    if (days == null || !mounted) return;
    await _subscription(context, SubscriptionAction.renew, days);
  }

  Future<void> _addNote(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: TextWidget('admin_add_note'.tr()),
        content: TextField(controller: controller, maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: TextWidget('cancel'.tr())),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: TextWidget('confirm'.tr()),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && result.isNotEmpty && mounted) {
      await context.read<UserDetailCubit>().addNote(result);
    }
  }

  Future<void> _editNote(BuildContext context, String noteId, String current) async {
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: TextWidget('admin_edit_note'.tr()),
        content: TextField(controller: controller, maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: TextWidget('cancel'.tr())),
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

  Future<void> _editUser(BuildContext context, dynamic user) async {
    final nameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phoneNumber);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: TextWidget('admin_edit_user'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'admin_full_name'.tr()),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'email_address'.tr()),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'customer_phone'.tr()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: TextWidget('cancel'.tr())),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: TextWidget('confirm'.tr())),
        ],
      ),
    );
    if (result == true && mounted) {
      final cubit = context.read<UserDetailCubit>();
      final ok = await cubit.updateUser(UpdateUserParams(
        uid: widget.uid,
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
      ));
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
      if (ok) showSuccessToast('admin_user_updated'.tr());
    } else {
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
    }
  }

  Future<void> _resetPassword(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: TextWidget('admin_reset_password'.tr()),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(hintText: 'password'.tr()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: TextWidget('cancel'.tr())),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: TextWidget('confirm'.tr()),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && result.length >= 6 && mounted) {
      final ok = await context.read<UserDetailCubit>().resetPassword(result);
      if (ok) showSuccessToast('admin_password_reset'.tr());
    }
  }

  Future<void> _confirmAction(
    BuildContext context,
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: TextWidget('cancel'.tr())),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: TextWidget('confirm'.tr())),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final ok = await action();
      if (ok) showSuccessToast(successKey.tr());
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: TextWidget('admin_delete_user'.tr()),
        content: TextWidget('admin_confirm_delete'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: TextWidget('cancel'.tr())),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: TextWidget('confirm'.tr())),
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
