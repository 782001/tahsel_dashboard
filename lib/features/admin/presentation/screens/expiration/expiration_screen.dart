import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/constants/admin_constants.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
import 'package:tahsel_dashboard/core/utils/styles.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/app_user.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/users/users_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/users/users_state.dart';
import 'package:tahsel_dashboard/features/admin/presentation/widgets/status_badge.dart';
import 'package:tahsel_dashboard/routes/app_routes.dart';
import 'package:tahsel_dashboard/shared/widgets/buttons/custom_button.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';
import 'package:tahsel_dashboard/shared/widgets/toast/custom_toast.dart';

class ExpirationScreen extends StatefulWidget {
  const ExpirationScreen({super.key});

  @override
  State<ExpirationScreen> createState() => _ExpirationScreenState();
}

class _ExpirationScreenState extends State<ExpirationScreen> {
  int _selectedDays = 7;

  @override
  void initState() {
    super.initState();
    context.read<ExpirationCubit>().load(withinDays: _selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: AdminConstants.expirationWindows.map((days) {
              final selected = _selectedDays == days;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: ChoiceChip(
                  label: Text('$days ${'admin_days'.tr()}'),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _selectedDays = days);
                    context.read<ExpirationCubit>().load(
                      withinDays: days,
                      refresh: true,
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: BlocBuilder<ExpirationCubit, UsersState>(
            builder: (context, state) {
              if (state is UsersLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    color: AppColors.primaryColor,
                  ),
                );
              }
              if (state is UsersError) {
                return Center(child: TextWidget(state.message));
              }
              if (state is UsersLoaded) {
                if (state.users.isEmpty) {
                  return Center(child: TextWidget('sorry_no_data'.tr()));
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n is ScrollEndNotification &&
                        n.metrics.pixels >= n.metrics.maxScrollExtent - 100) {
                      context.read<ExpirationCubit>().loadMore();
                    }
                    return false;
                  },
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: state.users.length + (state.hasMore ? 1 : 0),
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) {
                      if (index >= state.users.length) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        );
                      }
                      return _ExpirationTile(user: state.users[index]);
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _ExpirationTile extends StatelessWidget {
  final AppUser user;
  const _ExpirationTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    user.fullName,
                    style: TextStyles.font16WeightBoldText(),
                  ),
                  TextWidget(user.email),
                  Row(
                    children: [
                      StatusBadge(statusKey: user.subscriptionStatus),
                      SizedBox(width: 8.w),
                      TextWidget(
                        '${'admin_days_remaining'.tr()}: ${user.daysRemaining}',
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  CustomButton(
                    text: 'admin_quick_renew'.tr(),
                    width: 120.w,
                    height: 40.h,
                    onPressed: () async {
                      final ok = await context
                          .read<ExpirationCubit>()
                          .quickRenew(user.uid);
                      if (ok)
                        showSuccessToast('admin_subscription_updated'.tr());
                    },
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.userDetail,
                arguments: user.uid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
