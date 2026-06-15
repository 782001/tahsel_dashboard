import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
import 'package:tahsel_dashboard/core/utils/styles.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/audit_log.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/audit/audit_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/audit/audit_state.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';
import 'package:tahsel_dashboard/shared/widgets/toast/custom_toast.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuditCubit>().load();
  }

  Future<void> _onRefresh() => context.read<AuditCubit>().load();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuditCubit, AuditState>(
      // ── Only listen when a background loadMore fails ───────────────────
      listenWhen: (_, next) =>
          next is AuditLoaded && next.loadMoreError != null,
      listener: (context, state) {
        if (state is AuditLoaded && state.loadMoreError != null) {
          // Show toast without destroying the loaded list.
          showfailureToast(state.loadMoreError!);
          // Clear the error via the cubit so it won't fire again on the next rebuild.
          context.read<AuditCubit>().clearLoadMoreError();
        }
      },
      builder: (context, state) {
        // ── Full-screen loading (first load) ──────────────────────────────
        if (state is AuditLoading) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              color: AppColors.primaryColor,
            ),
          );
        }

        // ── Error state — scrollable so RefreshIndicator works ────────────
        if (state is AuditError) {
          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: _onRefresh,
            child: ListView(
              children: [
                SizedBox(height: 120.h),
                Center(child: TextWidget(state.message)),
                SizedBox(height: 16.h),
                Center(
                  child: TextButton.icon(
                    onPressed: _onRefresh,
                    icon: const Icon(Icons.refresh),
                    label: TextWidget('retry'.tr()),
                  ),
                ),
              ],
            ),
          );
        }

        // ── Loaded state ──────────────────────────────────────────────────
        if (state is AuditLoaded) {
          if (state.logs.isEmpty) {
            return RefreshIndicator(
              color: AppColors.primaryColor,
              onRefresh: _onRefresh,
              child: ListView(
                children: [
                  SizedBox(height: 120.h),
                  Center(child: TextWidget('sorry_no_data'.tr())),
                ],
              ),
            );
          }

          final df = DateFormat.yMMMd().add_Hm();
          // total items = logs + optional load-more spinner
          final itemCount = state.logs.length + (state.hasMore ? 1 : 0);

          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: _onRefresh,
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n is ScrollEndNotification &&
                    n.metrics.pixels >= n.metrics.maxScrollExtent - 100 &&
                    !state.isLoadingMore) {
                  context.read<AuditCubit>().loadMore();
                }
                return false;
              },
              child: ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: itemCount,
                separatorBuilder: (_, __) =>
                    Divider(color: AppColors.dividerColor),
                itemBuilder: (context, index) {
                  // Load-more spinner at the bottom
                  if (index >= state.logs.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  }
                  return _AuditTile(log: state.logs[index], dateFormat: df);
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

class _AuditTile extends StatelessWidget {
  final AuditLog log;
  final DateFormat dateFormat;
  const _AuditTile({required this.log, required this.dateFormat});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextWidget(
        log.actionType.replaceAll('_', ' '),
        style: TextStyles.font16WeightBoldText(),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget('${log.adminName} (${log.adminId})'),
          if (log.targetUserName != null)
            TextWidget('${'admin_target'.tr()}: ${log.targetUserName}'),
          if (log.metadata.containsKey('days') && log.metadata['days'] != null)
            TextWidget('${'days'.tr()}: ${log.metadata['days']}'),
          TextWidget(
            log.timestamp != null ? dateFormat.format(log.timestamp!) : '',
            style: TextStyles.font14Weight400RightAligned().copyWith(
              color: AppColors.subTitleColor,
            ),
          ),
        ],
      ),
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryColor.withValues(alpha: 0.15),
        child: Icon(Icons.history, color: AppColors.primaryColor, size: 20.sp),
      ),
    );
  }
}
