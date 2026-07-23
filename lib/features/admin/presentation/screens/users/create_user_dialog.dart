import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/constants/admin_constants.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/features/admin/domain/usecases/admin_usecases.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/users/users_cubit.dart';
import 'package:tahsel_dashboard/shared/widgets/buttons/custom_button.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';
import 'package:tahsel_dashboard/shared/widgets/text_fields/auth_custom_text_field.dart';
import 'package:tahsel_dashboard/features/admin/presentation/widgets/custom_days_dialog.dart';
import 'package:tahsel_dashboard/shared/widgets/toast/custom_toast.dart';

class CreateUserDialog extends StatefulWidget {
  const CreateUserDialog({super.key});

  @override
  State<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _projectName = TextEditingController();
  int _days = 30;
  String _userType = 'cafe';
  String _platformType = 'mobile';
  bool _isVip = false;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _projectName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextWidget('admin_create_user'.tr()),
      content: SizedBox(
        width: 400.w,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthTextFormField(
                label: 'admin_full_name'.tr(),
                controller: _name,
                textInputType: TextInputType.name,
              ),
              AuthTextFormField(
                label: 'email_address'.tr(),
                controller: _email,
                textInputType: TextInputType.emailAddress,
              ),
              AuthTextFormField(
                label: 'customer_phone'.tr(),
                controller: _phone,
                textInputType: TextInputType.phone,
              ),
              AuthTextFormField(
                label: 'password'.tr(),
                controller: _password,
                textInputType: TextInputType.visiblePassword,
                obscureText: true,
              ),
              AuthTextFormField(
                label: 'admin_project_name'.tr(),
                controller: _projectName,
                textInputType: TextInputType.name,
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<String>(
                initialValue: _userType,
                decoration: InputDecoration(labelText: 'admin_user_type'.tr()),
                items: [
                  DropdownMenuItem(
                    value: 'cafe',
                    child: TextWidget('user_type_cafe'.tr()),
                  ),
                  DropdownMenuItem(
                    value: 'shop',
                    child: TextWidget('user_type_shop'.tr()),
                  ),
                ],
                onChanged: (v) => setState(() => _userType = v ?? 'cafe'),
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<String>(
                initialValue: _platformType,
                decoration: InputDecoration(labelText: 'admin_platform_type'.tr()),
                items: [
                  DropdownMenuItem(
                    value: 'mobile',
                    child: TextWidget('platform_type_mobile'.tr()),
                  ),
                  DropdownMenuItem(
                    value: 'desktop',
                    child: TextWidget('platform_type_desktop'.tr()),
                  ),
                  DropdownMenuItem(
                    value: 'both',
                    child: TextWidget('platform_type_both'.tr()),
                  ),
                ],
                onChanged: (v) => setState(() => _platformType = v ?? 'mobile'),
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<int>(
                initialValue: _days,
                decoration: InputDecoration(labelText: 'admin_subscription_days'.tr()),
                items: [
                  ...AdminConstants.subscriptionPresets.map(
                    (d) => DropdownMenuItem(value: d, child: Text('$d ${'admin_days'.tr()}')),
                  ),
                  DropdownMenuItem(value: 0, child: Text('admin_custom_duration'.tr())),
                ],
                onChanged: (v) => setState(() => _days = v ?? 30),
              ),
              SizedBox(height: 12.h),
              SwitchListTile(
                title: const Text('VIP Account'),
                subtitle: Text(_isVip ? '☑ Enabled' : '☐ Disabled'),
                secondary: const Icon(Icons.workspace_premium_rounded, color: Colors.amber),
                value: _isVip,
                activeThumbColor: Colors.amber,
                onChanged: (val) => setState(() => _isVip = val),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: TextWidget('cancel'.tr()),
        ),
        CustomButton(
          text: 'confirm'.tr(),
          width: 120.w,
          isLoading: _loading,
          onPressed: () async {
            var days = _days == 0 ? 30 : _days;
            if (_days == 0 && context.mounted) {
              final custom = await showCustomDaysDialog(context);
              if (custom == null) return;
              days = custom;
            }
            setState(() => _loading = true);
            if (!context.mounted) return;
            final ok = await context.read<UsersCubit>().createUser(
                  CreateUserParams(
                    email: _email.text.trim(),
                    password: _password.text,
                    fullName: _name.text.trim(),
                    phoneNumber: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
                    projectName: _projectName.text.trim().isEmpty ? null : _projectName.text.trim(),
                    subscriptionDays: days,
                    userType: _userType,
                    platformType: _platformType,
                    isVip: _isVip,
                  ),
                );
            setState(() => _loading = false);
            if (ok && context.mounted) {
              showSuccessToast('admin_user_created'.tr());
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
