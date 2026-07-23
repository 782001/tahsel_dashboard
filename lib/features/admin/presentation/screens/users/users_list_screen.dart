import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
import 'package:tahsel_dashboard/core/utils/styles.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/app_user.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/users/users_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/users/users_state.dart';
import 'package:tahsel_dashboard/features/admin/presentation/screens/users/create_user_dialog.dart';
import 'package:tahsel_dashboard/features/admin/presentation/widgets/status_badge.dart';
import 'package:tahsel_dashboard/routes/app_routes.dart';
import 'package:tahsel_dashboard/shared/widgets/buttons/custom_button.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';
import 'package:tahsel_dashboard/shared/widgets/text_fields/custom_search_field.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<UsersCubit>().load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Expanded(
                child: CustomSearchField(
                  controller: _searchController,
                  hintText: 'admin_search_hint'.tr(),
                  onChanged: (v) => context.read<UsersCubit>().search(v),
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                width: 140.w,
                child: CustomButton(
                  text: 'admin_create_user'.tr(),
                  height: 48.h,
                  icon: Icons.add,
                  onPressed: () => _showCreateDialog(context),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<UsersCubit, UsersState>(
            builder: (context, state) {
              if (state is UsersLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    color: AppColors.primaryColor,
                  ),
                );
              }

              Future<void> onRefresh() => context.read<UsersCubit>().load();

              if (state is UsersError) {
                return RefreshIndicator(
                  color: AppColors.primaryColor,
                  onRefresh: onRefresh,
                  child: ListView(
                    children: [
                      SizedBox(height: 100.h),
                      Center(child: TextWidget(state.message)),
                    ],
                  ),
                );
              }
              if (state is UsersLoaded) {
                if (state.users.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primaryColor,
                    onRefresh: onRefresh,
                    child: ListView(
                      children: [
                        SizedBox(height: 100.h),
                        Center(child: TextWidget('sorry_no_data'.tr())),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primaryColor,
                  onRefresh: onRefresh,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n is ScrollEndNotification &&
                          n.metrics.pixels >= n.metrics.maxScrollExtent - 100) {
                        context.read<UsersCubit>().loadMore();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                        return _UserTile(user: state.users[index]);
                      },
                    ),
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

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<UsersCubit>(),
        child: const CreateUserDialog(),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final AppUser user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      child: ListTile(
        title: TextWidget(
          user.fullName,
          style: TextStyles.font16WeightBoldText(),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              user.email,
              style: TextStyles.font14Weight400RightAligned(),
            ),
            if (user.projectName.isNotEmpty) ...[
              SizedBox(height: 4.h),
              TextWidget(
                '${'admin_project_name'.tr()}: ${user.projectName}',
                style: TextStyles.font14Weight400RightAligned(),
              ),
            ],
            SizedBox(height: 4.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (user.isVip) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.workspace_premium_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'VIP',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  StatusBadge(statusKey: user.accountStatus),
                  SizedBox(width: 8.w),
                  StatusBadge(statusKey: user.subscriptionStatus),
                  SizedBox(width: 8.w),
                  StatusBadge(
                    statusKey: 'platform_type_${user.platformType}',
                  ),
                ],
              ),
            ),
            if (user.subscriptionEnd != null)
              TextWidget(
                '${'admin_days_remaining'.tr()}: ${user.daysRemaining}',
                style: TextStyles.font14Weight400RightAligned().copyWith(
                  color: AppColors.subTitleColor,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.userDetail,
          arguments: user.uid,
        ),
      ),
    );
  }
}
