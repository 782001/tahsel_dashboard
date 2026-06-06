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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuditCubit, AuditState>(
      builder: (context, state) {
        if (state is AuditLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AuditError) {
          return Center(child: TextWidget(state.message));
        }
        if (state is AuditLoaded) {
          final df = DateFormat.yMMMd().add_Hm();
          return NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollEndNotification &&
                  n.metrics.pixels >= n.metrics.maxScrollExtent - 100) {
                context.read<AuditCubit>().loadMore();
              }
              return false;
            },
            child: ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: state.logs.length,
              separatorBuilder: (_, __) =>
                  Divider(color: AppColors.dividerColor),
              itemBuilder: (context, index) {
                final log = state.logs[index];
                return _AuditTile(log: log, dateFormat: df);
              },
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
