import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/constants/app_rbac_catalog.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/core/services/injection_container.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
import 'package:tahsel_dashboard/core/utils/styles.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/tenant_employee.dart';
import 'package:tahsel_dashboard/features/admin/domain/usecases/admin_usecases.dart';
import 'package:tahsel_dashboard/features/admin/presentation/widgets/status_badge.dart';
import 'package:tahsel_dashboard/shared/widgets/buttons/custom_button.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';
import 'package:tahsel_dashboard/shared/widgets/toast/custom_toast.dart';

class EditEmployeePermissionsScreen extends StatefulWidget {
  final String ownerUid;
  final TenantEmployee employee;

  const EditEmployeePermissionsScreen({
    super.key,
    required this.ownerUid,
    required this.employee,
  });

  static Future<bool?> push(
    BuildContext context, {
    required String ownerUid,
    required TenantEmployee employee,
  }) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditEmployeePermissionsScreen(
          ownerUid: ownerUid,
          employee: employee,
        ),
      ),
    );
  }

  @override
  State<EditEmployeePermissionsScreen> createState() =>
      _EditEmployeePermissionsScreenState();
}

class _EditEmployeePermissionsScreenState
    extends State<EditEmployeePermissionsScreen> {
  late String _selectedPreset;
  late final Set<String> _selectedPermissions;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedPreset = widget.employee.rolePreset;
    _selectedPermissions = Set<String>.from(widget.employee.permissions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyPreset(String preset) {
    setState(() {
      _selectedPreset = preset;
      if (preset != AppRbacCatalog.roleCustom) {
        _selectedPermissions.clear();
        _selectedPermissions.addAll(
          AppRbacCatalog.resolveDependencies(
            AppRbacCatalog.permissionsForPreset(preset),
          ),
        );
      }
    });
  }

  void _togglePermission(String key) {
    setState(() {
      if (_selectedPermissions.contains(key)) {
        _selectedPermissions.remove(key);
        final dependents = AppRbacCatalog.getDependents(key);
        final removedDependents =
            dependents.where((d) => _selectedPermissions.contains(d)).toList();
        if (removedDependents.isNotEmpty) {
          _selectedPermissions.removeAll(dependents);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showDependencyToast(
              '${'perm_auto_disabled_dependents'.tr()}: ${removedDependents.map((k) => AppRbacCatalog.getPermissionLabel(k)).join('، ')}',
              isWarning: true,
            );
          });
        }
      } else {
        _selectedPermissions.add(key);
        final prerequisites = AppRbacCatalog.getPrerequisites(key);
        final addedPrerequisites = prerequisites
            .where((p) => !_selectedPermissions.contains(p))
            .toList();
        if (addedPrerequisites.isNotEmpty) {
          _selectedPermissions.addAll(prerequisites);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showDependencyToast(
              '${'perm_auto_enabled_prerequisites'.tr()}: ${addedPrerequisites.map((k) => AppRbacCatalog.getPermissionLabel(k)).join('، ')}',
            );
          });
        }
      }
      _selectedPreset = AppRbacCatalog.roleCustom;
    });
  }

  void _showDependencyToast(String message, {bool isWarning = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isWarning ? Icons.info_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            isWarning ? Colors.orange.shade800 : AppColors.primaryColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  void _selectAll() {
    setState(() {
      for (final group in AppRbacCatalog.groups) {
        for (final item in group.items) {
          _selectedPermissions.add(item.key);
        }
      }
      _selectedPreset = AppRbacCatalog.roleCustom;
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedPermissions.clear();
      _selectedPreset = AppRbacCatalog.roleCustom;
    });
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    final useCase = sl<UpdateTenantEmployeePermissionsUseCase>();
    final result = await useCase(
      UpdateTenantEmployeePermissionsParams(
        ownerUid: widget.ownerUid,
        employeeId: widget.employee.id,
        rolePreset: _selectedPreset,
        permissions: _selectedPermissions.toList(),
      ),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        showfailureToast(failure.message);
      },
      (_) {
        showSuccessToast('permissions_updated_success'.tr());
        Navigator.pop(context, true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scafoldBackGround,
      appBar: AppBar(
        title: TextWidget('edit_employee_permissions'.tr()),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: SizedBox(
              width: 140.w,
              child: CustomButton(
                text: 'save_changes'.tr(),
                color: AppColors.primaryColor,
                isLoading: _isLoading,
                onPressed: () => _submit(),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEmployeeHeaderCard(),
                SizedBox(height: 16.h),
                _buildPresetSelectorCard(),
                SizedBox(height: 16.h),
                _buildControlBarCard(),
                SizedBox(height: 16.h),
                _buildPermissionsList(),
                SizedBox(height: 24.h),
                _buildBottomActions(),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26.r,
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
            child: Text(
              widget.employee.name.isNotEmpty
                  ? widget.employee.name[0].toUpperCase()
                  : '؟',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.w,
                  runSpacing: 4.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TextWidget(
                      widget.employee.name,
                      style: TextStyles.appbartext().copyWith(fontSize: 18.sp),
                    ),
                    StatusBadge(statusKey: widget.employee.accountStatus),
                  ],
                ),
                SizedBox(height: 4.h),
                TextWidget(
                  widget.employee.email,
                  style: TextStyles.font14Weight400RightAligned().copyWith(
                    color: AppColors.subTitleColor,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                TextWidget(
                  '${'admin_uid'.tr()}: ${widget.employee.id}',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetSelectorCard() {
    final presets = [
      (AppRbacCatalog.roleCashier, 'preset_cashier'.tr(), Icons.point_of_sale_rounded),
      (AppRbacCatalog.roleStorekeeper, 'preset_storekeeper'.tr(), Icons.inventory_2_outlined),
      (AppRbacCatalog.roleAccountant, 'preset_accountant'.tr(), Icons.account_balance_wallet_outlined),
      (AppRbacCatalog.roleSupervisor, 'preset_supervisor'.tr(), Icons.admin_panel_settings_outlined),
      (AppRbacCatalog.roleCustom, 'preset_custom'.tr(), Icons.tune_rounded),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.badge_outlined, color: AppColors.primaryColor, size: 20.sp),
              SizedBox(width: 8.w),
              TextWidget(
                'role_preset'.tr(),
                style: TextStyles.font18Weight500Action().copyWith(fontSize: 15.sp),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: presets.map((p) {
              final isSelected = _selectedPreset == p.$1;
              return ChoiceChip(
                showCheckmark: false,
                avatar: Icon(
                  p.$3,
                  size: 16.sp,
                  color: isSelected ? Colors.white : AppColors.primaryColor,
                ),
                label: TextWidget(
                  p.$2,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primaryColor,
                backgroundColor: AppColors.scafoldBackGround,
                onSelected: (_) => _applyPreset(p.$1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBarCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'search_permissions'.tr(),
                    hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.scafoldBackGround,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_outlined, size: 16.sp, color: AppColors.primaryColor),
                    SizedBox(width: 6.w),
                    TextWidget(
                      '${_selectedPermissions.length} / ${AppRbacCatalog.totalPermissions}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _selectAll,
                icon: const Icon(Icons.select_all_rounded, size: 16),
                label: TextWidget('select_all'.tr(), style: TextStyle(fontSize: 12.sp)),
              ),
              SizedBox(width: 8.w),
              TextButton.icon(
                onPressed: _deselectAll,
                icon: const Icon(Icons.deselect_rounded, size: 16),
                label: TextWidget(
                  'deselect_all'.tr(),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsList() {
    final filteredGroups = AppRbacCatalog.groups.map((group) {
      if (_searchQuery.isEmpty) return group;
      final matchedItems = group.items.where((item) {
        return item.titleAr.toLowerCase().contains(_searchQuery) ||
            item.titleEn.toLowerCase().contains(_searchQuery) ||
            item.key.toLowerCase().contains(_searchQuery);
      }).toList();
      return AppPermissionGroup(
        id: group.id,
        titleAr: group.titleAr,
        titleEn: group.titleEn,
        items: matchedItems,
      );
    }).where((g) => g.items.isNotEmpty).toList();

    if (filteredGroups.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, size: 48.sp, color: Colors.grey[300]),
              SizedBox(height: 8.h),
              TextWidget('no_data'.tr(), style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }

    return Column(
      children: filteredGroups.map((group) {
        final activeInGroup = group.items
            .where((item) => _selectedPermissions.contains(item.key))
            .length;
        final totalInGroup = group.items.length;
        final isAllActive = activeInGroup == totalInGroup && totalInGroup > 0;

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: activeInGroup > 0
                  ? AppColors.primaryColor.withValues(alpha: 0.25)
                  : Colors.grey.shade200,
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              title: Row(
                children: [
                  Expanded(
                    child: TextWidget(
                      group.titleAr,
                      style: TextStyles.font18Weight500Action().copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isAllActive
                          ? AppColors.success.withValues(alpha: 0.12)
                          : activeInGroup > 0
                              ? Colors.orange.withValues(alpha: 0.12)
                              : Colors.grey.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: TextWidget(
                      '$activeInGroup / $totalInGroup',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: isAllActive
                            ? AppColors.success
                            : activeInGroup > 0
                                ? Colors.orange
                                : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              children: group.items.map((item) {
                final isChecked = _selectedPermissions.contains(item.key);
                final hasPrereqs = AppRbacCatalog.hasPrerequisites(item.key);

                return CheckboxListTile(
                  value: isChecked,
                  onChanged: (_) => _togglePermission(item.key),
                  activeColor: AppColors.primaryColor,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
                  title: Row(
                    children: [
                      Expanded(
                        child: TextWidget(
                          item.titleAr,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
                            color: isChecked ? Colors.black87 : Colors.grey[700],
                          ),
                        ),
                      ),
                      TextWidget(
                        item.key,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontFamily: 'monospace',
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  subtitle: hasPrereqs
                      ? Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              Icon(
                                Icons.link_rounded,
                                size: 13,
                                color: AppColors.primaryColor.withValues(alpha: 0.75),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: TextWidget(
                                  '${'perm_requires_prefix'.tr()}: ${AppRbacCatalog.getPrerequisiteLabels(item.key)}',
                                  style: TextStyles.customStyle(
                                    fontSize: 11,
                                    color: AppColors.subTitleColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                );
              }).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          child: TextWidget('cancel'.tr()),
        ),
        SizedBox(width: 12.w),
        SizedBox(
          width: 180.w,
          child: CustomButton(
            text: 'save_changes'.tr(),
            color: AppColors.primaryColor,
            isLoading: _isLoading,
            onPressed: () => _submit(),
          ),
        ),
      ],
    );
  }
}
