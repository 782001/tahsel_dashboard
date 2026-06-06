import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/app_settings.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/settings/settings_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/settings/settings_state.dart';
import 'package:tahsel_dashboard/shared/widgets/buttons/custom_button.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/quick_text_field.dart' show QuickAddTextField;
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';
import 'package:tahsel_dashboard/shared/widgets/toast/custom_toast.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final _minVersion = TextEditingController();
  final _latestVersion = TextEditingController();
  bool _forceUpdate = false;

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().load();
  }

  @override
  void dispose() {
    _minVersion.dispose();
    _latestVersion.dispose();
    super.dispose();
  }

  void _bindSettings(AppSettings settings) {
    _minVersion.text = settings.minSupportedVersion;
    _latestVersion.text = settings.latestVersion;
    _forceUpdate = settings.forceUpdate;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoaded) _bindSettings(state.settings);
        if (state is SettingsSaved) showSuccessToast('admin_settings_saved'.tr());
      },
      builder: (context, state) {
        if (state is SettingsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget('admin_app_version_settings'.tr(),
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 16.h),
                QuickAddTextField(
                  controller: _minVersion,
                  hint: 'admin_min_supported_version'.tr(),
                ),
                SizedBox(height: 12.h),
                QuickAddTextField(
                  controller: _latestVersion,
                  hint: 'admin_latest_version'.tr(),
                ),
                SizedBox(height: 12.h),
                SwitchListTile(
                  title: TextWidget('admin_force_update'.tr()),
                  value: _forceUpdate,
                  onChanged: (v) => setState(() => _forceUpdate = v),
                ),
                SizedBox(height: 24.h),
                CustomButton(
                  text: 'confirm'.tr(),
                  isLoading: state is SettingsSaving,
                  onPressed: () {
                    context.read<SettingsCubit>().save(AppSettings(
                          minSupportedVersion: _minVersion.text.trim(),
                          latestVersion: _latestVersion.text.trim(),
                          forceUpdate: _forceUpdate,
                        ));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
