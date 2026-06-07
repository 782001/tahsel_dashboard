import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/notifications/notifications_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/notifications/notifications_state.dart';
import 'package:tahsel_dashboard/shared/widgets/buttons/custom_button.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/quick_text_field.dart'
    show QuickAddTextField;
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';
import 'package:tahsel_dashboard/shared/widgets/toast/custom_toast.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  String _targetType = 'all';

  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().load();
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                'admin_send_notification'.tr(),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              QuickAddTextField(
                controller: _title,
                hint: 'admin_notification_title'.tr(),
              ),
              SizedBox(height: 8.h),
              QuickAddTextField(
                controller: _body,
                hint: 'admin_notification_body'.tr(),
              ),
              SizedBox(height: 8.h),
              DropdownButtonFormField<String>(
                value: _targetType,
                decoration: InputDecoration(
                  labelText: 'admin_target_type'.tr(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'all',
                    child: Text('admin_target_all'.tr()),
                  ),
                  DropdownMenuItem(
                    value: 'specific',
                    child: Text('admin_target_specific'.tr()),
                  ),
                  DropdownMenuItem(
                    value: 'group',
                    child: Text('admin_target_group'.tr()),
                  ),
                ],
                onChanged: (v) => setState(() => _targetType = v ?? 'all'),
              ),
              SizedBox(height: 16.h),
              CustomButton(
                text: 'admin_send'.tr(),
                onPressed: () async {
                  final ok = await context.read<NotificationsCubit>().send(
                    title: _title.text,
                    body: _body.text,
                    targetType: _targetType,
                  );
                  if (ok) {
                    showSuccessToast('admin_notification_sent'.tr());
                    _title.clear();
                    _body.clear();
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is NotificationsLoaded) {
                final df = DateFormat.yMMMd();
                return ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final n = state.items[index];
                    return ListTile(
                      title: TextWidget(n.title),
                      subtitle: TextWidget(
                        '${n.body}\n${n.adminName} • ${n.createdAt != null ? df.format(n.createdAt!) : ''}',
                      ),
                    );
                  },
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
