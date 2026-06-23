import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/app_settings.dart';
import 'package:tahsel_dashboard/features/admin/domain/repositories/admin_repository.dart'
    show ReleasePlatform;
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

class _SystemSettingsScreenState extends State<SystemSettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // ─── Android controllers ──────────────────────────────────────────────────
  final _aVersionName = TextEditingController();
  final _aBuildNumber = TextEditingController();
  final _aDownloadUrl = TextEditingController();
  final _aUpdateTitle = TextEditingController();
  final _aUpdateMessage = TextEditingController();
  final _aReleaseNotes = TextEditingController();
  bool _aForceUpdate = false;

  // ─── iOS controllers ──────────────────────────────────────────────────────
  final _iVersionName = TextEditingController();
  final _iBuildNumber = TextEditingController();
  final _iDownloadUrl = TextEditingController();
  final _iUpdateTitle = TextEditingController();
  final _iUpdateMessage = TextEditingController();
  final _iReleaseNotes = TextEditingController();
  bool _iForceUpdate = false;

  // ─── Windows controllers ──────────────────────────────────────────────────
  final _wVersionName = TextEditingController();
  final _wBuildNumber = TextEditingController();
  final _wDownloadUrl = TextEditingController();
  final _wUpdateTitle = TextEditingController();
  final _wUpdateMessage = TextEditingController();
  final _wReleaseNotes = TextEditingController();
  bool _wForceUpdate = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<SettingsCubit>().load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _aVersionName.dispose();
    _aBuildNumber.dispose();
    _aDownloadUrl.dispose();
    _aUpdateTitle.dispose();
    _aUpdateMessage.dispose();
    _aReleaseNotes.dispose();
    _iVersionName.dispose();
    _iBuildNumber.dispose();
    _iDownloadUrl.dispose();
    _iUpdateTitle.dispose();
    _iUpdateMessage.dispose();
    _iReleaseNotes.dispose();
    _wVersionName.dispose();
    _wBuildNumber.dispose();
    _wDownloadUrl.dispose();
    _wUpdateTitle.dispose();
    _wUpdateMessage.dispose();
    _wReleaseNotes.dispose();
    super.dispose();
  }

  void _bindSettings(AppSettings s) {
    // Android
    _aVersionName.text = s.android.versionName;
    _aBuildNumber.text = s.android.buildNumber.toString();
    _aDownloadUrl.text = s.android.downloadUrl;
    _aUpdateTitle.text = s.android.updateTitle;
    _aUpdateMessage.text = s.android.updateMessage;
    _aReleaseNotes.text = s.android.releaseNotes;
    _aForceUpdate = s.android.forceUpdate;
    // iOS
    _iVersionName.text = s.ios.versionName;
    _iBuildNumber.text = s.ios.buildNumber.toString();
    _iDownloadUrl.text = s.ios.downloadUrl;
    _iUpdateTitle.text = s.ios.updateTitle;
    _iUpdateMessage.text = s.ios.updateMessage;
    _iReleaseNotes.text = s.ios.releaseNotes;
    _iForceUpdate = s.ios.forceUpdate;
    // Windows
    _wVersionName.text = s.windows.versionName;
    _wBuildNumber.text = s.windows.buildNumber.toString();
    _wDownloadUrl.text = s.windows.downloadUrl;
    _wUpdateTitle.text = s.windows.updateTitle;
    _wUpdateMessage.text = s.windows.updateMessage;
    _wReleaseNotes.text = s.windows.releaseNotes;
    _wForceUpdate = s.windows.forceUpdate;
  }

  void _saveAndroid(SettingsCubit cubit) {
    cubit.savePlatformRelease(
      ReleasePlatform.android,
      PlatformRelease(
        versionName: _aVersionName.text.trim(),
        buildNumber: int.tryParse(_aBuildNumber.text.trim()) ?? 1,
        downloadUrl: _aDownloadUrl.text.trim(),
        forceUpdate: _aForceUpdate,
        updateTitle: _aUpdateTitle.text.trim(),
        updateMessage: _aUpdateMessage.text.trim(),
        releaseNotes: _aReleaseNotes.text.trim(),
      ),
    );
  }

  void _saveIos(SettingsCubit cubit) {
    cubit.savePlatformRelease(
      ReleasePlatform.ios,
      PlatformRelease(
        versionName: _iVersionName.text.trim(),
        buildNumber: int.tryParse(_iBuildNumber.text.trim()) ?? 1,
        downloadUrl: _iDownloadUrl.text.trim(),
        forceUpdate: _iForceUpdate,
        updateTitle: _iUpdateTitle.text.trim(),
        updateMessage: _iUpdateMessage.text.trim(),
        releaseNotes: _iReleaseNotes.text.trim(),
      ),
    );
  }

  void _saveWindows(SettingsCubit cubit) {
    cubit.savePlatformRelease(
      ReleasePlatform.windows,
      PlatformRelease(
        versionName: _wVersionName.text.trim(),
        buildNumber: int.tryParse(_wBuildNumber.text.trim()) ?? 1,
        downloadUrl: _wDownloadUrl.text.trim(),
        forceUpdate: _wForceUpdate,
        updateTitle: _wUpdateTitle.text.trim(),
        updateMessage: _wUpdateMessage.text.trim(),
        releaseNotes: _wReleaseNotes.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoaded) {
          _bindSettings(state.settings);
          setState(() {});
        }
        if (state is SettingsSavedAndroid) {
          showSuccessToast('admin_settings_saved_android'.tr());
        }
        if (state is SettingsSavedIos) {
          showSuccessToast('admin_settings_saved_ios'.tr());
        }
        if (state is SettingsSavedWindows) {
          showSuccessToast('admin_settings_saved_windows'.tr());
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

        final cubit = context.read<SettingsCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
              child: TextWidget(
                'admin_app_version_settings'.tr(),
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16.h),

            // ─── Tab bar ───────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.stitchSurfaceHigh.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.blackLight,
                  labelStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    Tab(
                      icon: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.android),
                      ),
                    ),
                    Tab(
                      icon: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.apple),
                      ),
                    ),
                    Tab(
                      icon: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.window),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),

            // ─── Tab views ─────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── Android ──
                  _PlatformReleaseForm(
                    versionName: _aVersionName,
                    buildNumber: _aBuildNumber,
                    downloadUrl: _aDownloadUrl,
                    updateTitle: _aUpdateTitle,
                    updateMessage: _aUpdateMessage,
                    releaseNotes: _aReleaseNotes,
                    forceUpdate: _aForceUpdate,
                    onForceUpdateChanged: (v) =>
                        setState(() => _aForceUpdate = v),
                    isLoading: state is SettingsSavingAndroid,
                    saveLabelKey: 'admin_save_android',
                    platformIcon: Icons.android,
                    platformColor: const Color(0xFF3DDC84),
                    onSave: () => _saveAndroid(cubit),
                  ),

                  // ── iOS ──
                  _PlatformReleaseForm(
                    versionName: _iVersionName,
                    buildNumber: _iBuildNumber,
                    downloadUrl: _iDownloadUrl,
                    updateTitle: _iUpdateTitle,
                    updateMessage: _iUpdateMessage,
                    releaseNotes: _iReleaseNotes,
                    forceUpdate: _iForceUpdate,
                    onForceUpdateChanged: (v) =>
                        setState(() => _iForceUpdate = v),
                    isLoading: state is SettingsSavingIos,
                    saveLabelKey: 'admin_save_ios',
                    platformIcon: Icons.apple,
                    platformColor: const Color(0xFF555555),
                    onSave: () => _saveIos(cubit),
                  ),

                  // ── Windows ──
                  _PlatformReleaseForm(
                    versionName: _wVersionName,
                    buildNumber: _wBuildNumber,
                    downloadUrl: _wDownloadUrl,
                    updateTitle: _wUpdateTitle,
                    updateMessage: _wUpdateMessage,
                    releaseNotes: _wReleaseNotes,
                    forceUpdate: _wForceUpdate,
                    onForceUpdateChanged: (v) =>
                        setState(() => _wForceUpdate = v),
                    isLoading: state is SettingsSavingWindows,
                    saveLabelKey: 'admin_save_windows',
                    platformIcon: Icons.window,
                    platformColor: const Color(0xFF0078D4),
                    onSave: () => _saveWindows(cubit),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Reusable per-platform form ───────────────────────────────────────────────

class _PlatformReleaseForm extends StatelessWidget {
  const _PlatformReleaseForm({
    required this.versionName,
    required this.buildNumber,
    required this.downloadUrl,
    required this.updateTitle,
    required this.updateMessage,
    required this.releaseNotes,
    required this.forceUpdate,
    required this.onForceUpdateChanged,
    required this.isLoading,
    required this.saveLabelKey,
    required this.platformIcon,
    required this.platformColor,
    required this.onSave,
  });

  final TextEditingController versionName;
  final TextEditingController buildNumber;
  final TextEditingController downloadUrl;
  final TextEditingController updateTitle;
  final TextEditingController updateMessage;
  final TextEditingController releaseNotes;
  final bool forceUpdate;
  final ValueChanged<bool> onForceUpdateChanged;
  final bool isLoading;
  final String saveLabelKey;
  final IconData platformIcon;
  final Color platformColor;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Platform badge
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: platformColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(platformIcon, color: platformColor, size: 20.sp),
                ),
                SizedBox(width: 10.w),
                TextWidget(
                  saveLabelKey.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: platformColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // ─── Version Name ─────────────────────────────────────────────
            _FieldLabel('admin_version_name'.tr()),
            SizedBox(height: 6.h),
            QuickAddTextField(
              controller: versionName,
              hint: 'admin_version_name_hint'.tr(),
            ),
            SizedBox(height: 16.h),

            // ─── Build Number ─────────────────────────────────────────────
            _FieldLabel('admin_build_number'.tr()),
            SizedBox(height: 6.h),
            QuickAddTextField(
              controller: buildNumber,
              hint: 'admin_build_number_hint'.tr(),
              isNumber: true,
            ),
            SizedBox(height: 16.h),

            // ─── Download / Store URL ─────────────────────────────────────
            _FieldLabel('admin_store_url'.tr()),
            SizedBox(height: 6.h),
            QuickAddTextField(
              controller: downloadUrl,
              hint: 'admin_store_url_hint'.tr(),
            ),
            SizedBox(height: 16.h),

            // ─── Divider: Update Config ───────────────────────────────────
            _SectionDivider('admin_update_config'.tr()),
            SizedBox(height: 12.h),

            // ─── Force Update toggle ──────────────────────────────────────
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: TextWidget('admin_force_update'.tr()),
              activeThumbColor: platformColor,
              value: forceUpdate,
              onChanged: onForceUpdateChanged,
            ),
            SizedBox(height: 12.h),

            // ─── Update Title ─────────────────────────────────────────────
            _FieldLabel('admin_update_title'.tr()),
            SizedBox(height: 6.h),
            QuickAddTextField(
              controller: updateTitle,
              hint: 'admin_update_title_hint'.tr(),
            ),
            SizedBox(height: 16.h),

            // ─── Update Message ───────────────────────────────────────────
            _FieldLabel('admin_update_message'.tr()),
            SizedBox(height: 6.h),
            _MultilineField(
              controller: updateMessage,
              hint: 'admin_update_message_hint'.tr(),
              maxLines: 3,
            ),
            SizedBox(height: 16.h),

            // ─── Release Notes ────────────────────────────────────────────
            _FieldLabel('admin_release_notes'.tr()),
            SizedBox(height: 6.h),
            _MultilineField(
              controller: releaseNotes,
              hint: 'admin_release_notes_hint'.tr(),
              maxLines: 4,
            ),
            SizedBox(height: 28.h),

            // ─── Save button ──────────────────────────────────────────────
            CustomButton(
              text: isLoading ? 'admin_saving'.tr() : saveLabelKey.tr(),
              isLoading: isLoading,
              onPressed: onSave,
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

// ─── Small helper widgets ─────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return TextWidget(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        color: Colors.grey,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: TextWidget(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _MultilineField extends StatelessWidget {
  const _MultilineField({
    required this.controller,
    required this.hint,
    this.maxLines = 3,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.stitchSurfaceHigh.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
      ),
    );
  }
}
