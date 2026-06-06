import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/dashboard/dashboard_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/dashboard/dashboard_state.dart';
import 'package:tahsel_dashboard/features/admin/presentation/widgets/stat_card.dart';
import 'package:tahsel_dashboard/shared/widgets/empty_widget/empty_widget.dart';
import 'package:tahsel_dashboard/shared/widgets/shimmer/shimmer_loading.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return ShimmerLoading(
            child: GridView.count(
              crossAxisCount: 2,
              children: List.generate(
                6,
                (_) => Container(
                  margin: const EdgeInsets.all(8),
                  color: Colors.white,
                ),
              ),
            ),
          );
        }
        if (state is DashboardError) {
          return EmptyWidget(title: state.message);
        }
        if (state is DashboardLoaded) {
          final s = state.stats;
          final currency = NumberFormat.compact();
          return RefreshIndicator(
            onRefresh: () => context.read<DashboardCubit>().load(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossCount = constraints.maxWidth > 900
                      ? 3
                      : constraints.maxWidth > 600
                          ? 2
                          : 1;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossCount,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    childAspectRatio: 1.6,
                    children: [
                      StatCard(
                        title: 'admin_stat_total_users'.tr(),
                        value: '${s.totalUsers}',
                        icon: Icons.people,
                      ),
                      StatCard(
                        title: 'admin_stat_active_users'.tr(),
                        value: '${s.activeUsers}',
                        icon: Icons.person_outline,
                      ),
                      StatCard(
                        title: 'admin_stat_suspended'.tr(),
                        value: '${s.suspendedUsers}',
                        icon: Icons.block,
                      ),
                      StatCard(
                        title: 'admin_stat_expired'.tr(),
                        value: '${s.expiredSubscriptions}',
                        icon: Icons.event_busy,
                      ),
                      StatCard(
                        title: 'admin_stat_expiring_soon'.tr(),
                        value: '${s.expiringSoon}',
                        icon: Icons.warning_amber,
                      ),
                      StatCard(
                        title: 'admin_stat_new_month'.tr(),
                        value: '${s.newUsersThisMonth}',
                        icon: Icons.person_add,
                      ),
                      StatCard(
                        title: 'admin_stat_monthly_revenue'.tr(),
                        value: currency.format(s.monthlyRevenue),
                        icon: Icons.attach_money,
                        color: Colors.green,
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
