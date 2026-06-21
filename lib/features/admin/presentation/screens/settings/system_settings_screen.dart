import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/app_settings.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/settings/settings_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/settings/settings_state.dart';
import 'package:tahsel_dashboard/shared/widgets/buttons/custom_button.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/quick_text_field.dart'
    show QuickAddTextField;
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';
import 'package:tahsel_dashboard/shared/widgets/toast/custom_toast.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final _androidUrl = TextEditingController();
  final _windowsUrl = TextEditingController();
  final _iosUrl = TextEditingController();
  final _latestVersion = TextEditingController();
  final _versionName = TextEditingController();
  final _updateMessage = TextEditingController();
  bool _forceUpdate = false;

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().load();
  }

  @override
  void dispose() {
    _androidUrl.dispose();
    _windowsUrl.dispose();
    _iosUrl.dispose();
    _latestVersion.dispose();
    _versionName.dispose();
    _updateMessage.dispose();
    super.dispose();
  }

  void _bindSettings(AppSettings settings) {
    _androidUrl.text = settings.androidDownloadUrl;
    _windowsUrl.text = settings.windowsDownloadUrl;
    _iosUrl.text = settings.iosDownloadUrl;
    _latestVersion.text = settings.latestVersion.toString();
    _versionName.text = settings.versionName;
    _updateMessage.text = settings.updateMessage;
    _forceUpdate = settings.forceUpdate;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoaded) {
          _bindSettings(state.settings);
          setState(() {});
        }
        if (state is SettingsSaved) {
          showSuccessToast('admin_settings_saved'.tr());
        }
        if (state is SettingsError) {
          showfailureToast(state.message);
        }
      },
      builder: (context, state) {
        if (state is SettingsLoading) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              color: AppColors.primaryColor,
            ),
          );
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 560.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Section title ───────────────────────────────────────
                TextWidget(
                  'admin_app_version_settings'.tr(),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),

                // ─── latest_version ──────────────────────────────────────
                TextWidget(
                  'admin_latest_version'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                QuickAddTextField(
                  controller: _latestVersion,
                  hint: 'admin_latest_version_hint'.tr(),
                  isNumber: true,
                ),
                SizedBox(height: 16.h),

                // ─── version_name ─────────────────────────────────────────
                TextWidget(
                  'admin_version_name'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                QuickAddTextField(
                  controller: _versionName,
                  hint: 'admin_version_name_hint'.tr(),
                ),
                SizedBox(height: 16.h),

                // ─── Divider: Download URLs ───────────────────────────────
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: TextWidget(
                        'admin_download_urls'.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 16.h),

                // ─── android_download_url ─────────────────────────────────
                TextWidget(
                  'admin_android_url'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                QuickAddTextField(
                  controller: _androidUrl,
                  hint: 'admin_android_url_hint'.tr(),
                ),
                SizedBox(height: 16.h),

                // ─── windows_download_url ─────────────────────────────────
                TextWidget(
                  'admin_windows_url'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                QuickAddTextField(
                  controller: _windowsUrl,
                  hint: 'admin_windows_url_hint'.tr(),
                ),
                SizedBox(height: 16.h),

                // ─── ios_download_url ─────────────────────────────────────
                TextWidget(
                  'admin_ios_url'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                QuickAddTextField(
                  controller: _iosUrl,
                  hint: 'admin_ios_url_hint'.tr(),
                ),
                SizedBox(height: 16.h),

                // ─── Divider: Update Config ───────────────────────────────
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: TextWidget(
                        'admin_update_config'.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 12.h),

                // ─── force_update ─────────────────────────────────────────
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: TextWidget('admin_force_update'.tr()),
                  value: _forceUpdate,
                  onChanged: (v) => setState(() => _forceUpdate = v),
                ),
                SizedBox(height: 12.h),

                // ─── update_message ───────────────────────────────────────
                TextWidget(
                  'admin_update_message'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: _updateMessage,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'admin_update_message_hint'.tr(),
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
                SizedBox(height: 28.h),

                // ─── Save button ──────────────────────────────────────────
                CustomButton(
                  text: 'confirm'.tr(),
                  isLoading: state is SettingsSaving,
                  onPressed: () {
                    final parsedVersion =
                        int.tryParse(_latestVersion.text.trim()) ?? 1;
                    context.read<SettingsCubit>().save(
                          AppSettings(
                            androidDownloadUrl: _androidUrl.text.trim(),
                            windowsDownloadUrl: _windowsUrl.text.trim(),
                            iosDownloadUrl: _iosUrl.text.trim(),
                            latestVersion: parsedVersion,
                            versionName: _versionName.text.trim(),
                            forceUpdate: _forceUpdate,
                            updateMessage: _updateMessage.text.trim(),
                          ),
                        );
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
