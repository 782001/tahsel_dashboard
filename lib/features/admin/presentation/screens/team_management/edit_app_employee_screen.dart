import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/constants/app_permissions.dart';
import 'package:tahsel_dashboard/core/extensions/auth_context_extensions.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
import 'package:tahsel_dashboard/core/utils/styles.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/tenant_employee.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/team_management/team_management_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/widgets/status_badge.dart';
import 'package:tahsel_dashboard/shared/widgets/custom_app_bar/custom_app_bar.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';

class EditAppEmployeeScreen extends StatefulWidget {
  final String ownerUid;
  final TenantEmployee employee;
  final TeamManagementCubit cubit;
  final String? initialUserType;

  const EditAppEmployeeScreen({
    super.key,
    required this.ownerUid,
    required this.employee,
    required this.cubit,
    this.initialUserType,
  });

  static Future<void> push(
    BuildContext context, {
    required String ownerUid,
    required TenantEmployee employee,
    required TeamManagementCubit cubit,
    String? userType,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditAppEmployeeScreen(
          ownerUid: ownerUid,
          employee: employee,
          cubit: cubit,
          initialUserType: userType,
        ),
      ),
    );
  }

  @override
  State<EditAppEmployeeScreen> createState() => _EditAppEmployeeScreenState();
}

class _EditAppEmployeeScreenState extends State<EditAppEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  late String _selectedPreset;
  late final Set<String> _selectedPermissions;
  late bool _isShop;
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isShop = widget.initialUserType != 'cafe';
    _nameController = TextEditingController(text: widget.employee.name);
    _selectedPreset = widget.employee.rolePreset;
    _selectedPermissions = Set<String>.from(widget.employee.permissions);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _applyPreset(String preset) {
    setState(() {
      _selectedPreset = preset;
      if (preset != AppPermissions.roleCustom) {
        _selectedPermissions.clear();
        _selectedPermissions.addAll(
          AppPermissions.permissionsForPreset(preset, isShop: _isShop),
        );
      }
    });
  }

  void _toggleBusinessType(bool isShop) {
    setState(() {
      _isShop = isShop;
      final allowedKeys = AppPermissions.getGroupsForBusinessType(isShop: _isShop)
          .expand((g) => g.items.map((i) => i.key))
          .toSet();
      _selectedPermissions.removeWhere((p) => !allowedKeys.contains(p));
      if (_selectedPreset != AppPermissions.roleCustom) {
        _selectedPermissions.clear();
        _selectedPermissions.addAll(
          AppPermissions.permissionsForPreset(_selectedPreset, isShop: _isShop),
        );
      }
    });
  }

  void _togglePermission(String key) {
    setState(() {
      if (_selectedPermissions.contains(key)) {
        _selectedPermissions.remove(key);
        final dependents = AppPermissions.getDependents(key);
        final removedDependents = dependents
            .where((d) => _selectedPermissions.contains(d))
            .toList();
        if (removedDependents.isNotEmpty) {
          _selectedPermissions.removeAll(dependents);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showDependencyToast(
              'تم إيقاف الصلاحيات المعتمدة عليها تلقائياً: ${removedDependents.map((k) => AppPermissions.getPermissionLabel(k)).join('، ')}',
              isWarning: true,
            );
          });
        }
      } else {
        _selectedPermissions.add(key);
        final prerequisites = AppPermissions.getPrerequisites(key);
        final addedPrerequisites = prerequisites
            .where((p) => !_selectedPermissions.contains(p))
            .toList();
        if (addedPrerequisites.isNotEmpty) {
          _selectedPermissions.addAll(prerequisites);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showDependencyToast(
              'تم تفعيل الصلاحيات المتطلبة تلقائياً: ${addedPrerequisites.map((k) => AppPermissions.getPermissionLabel(k)).join('، ')}',
            );
          });
        }
      }
      _selectedPreset = AppPermissions.roleCustom;
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
              isWarning ? Icons.info_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyles.customStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isWarning
            ? Colors.orange.shade800
            : AppColors.primaryColor,
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
      for (final group in AppPermissions.getGroupsForBusinessType(isShop: _isShop)) {
        for (final item in group.items) {
          _selectedPermissions.add(item.key);
        }
      }
      _selectedPreset = AppPermissions.roleCustom;
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedPermissions.clear();
      _selectedPreset = AppPermissions.roleCustom;
    });
  }

  void _showValidationError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        backgroundColor: AppColors.error,
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                message,
                style: TextStyles.customStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: label,
          style: TextStyles.customStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          children: [
            if (isRequired)
              TextSpan(
                text: ' *',
                style: TextStyles.customStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!context.canWriteUsers) {
      _showValidationError('غير مصرح لك بتعديل الموظفين');
      return;
    }

    final trimmedName = _nameController.text.trim();
    if (trimmedName.isEmpty) {
      _showValidationError('اسم الموظف مطلوب');
      return;
    }

    if (_selectedPermissions.isEmpty) {
      _showValidationError('يرجى تحديد صلاحية واحدة على الأقل');
      return;
    }

    setState(() => _isLoading = true);

    final success = await widget.cubit.updateEmployee(
      ownerUid: widget.ownerUid,
      employeeId: widget.employee.id,
      name: trimmedName,
      rolePreset: _selectedPreset,
      permissions: _selectedPermissions.toList(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!context.canWriteUsers) {
      return Scaffold(
        backgroundColor: AppColors.scafoldBackGround,
        appBar: CustomAppBar(
          centerTitle: 'تعديل صلاحيات الموظف',
          leadingIcon: const Icon(Icons.arrow_back_ios_new_rounded),
          onLeadingTap: () => Navigator.pop(context),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 48.sp, color: AppColors.error),
                SizedBox(height: 12.h),
                TextWidget(
                  'غير مصرح لك بتعديل بيانات الموظفين',
                  style: TextStyles.font16WeightBoldText(),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const TextWidget('رجوع'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return BlocProvider.value(
      value: widget.cubit,
      child: Scaffold(
        backgroundColor: AppColors.scafoldBackGround,
        appBar: CustomAppBar(
          centerTitle: 'تعديل صلاحيات الموظف',
          leadingIcon: const Icon(Icons.arrow_back_ios_new_rounded),
          onLeadingTap: () => Navigator.pop(context),
          actionIcon: Padding(
            padding: EdgeInsetsDirectional.only(end: 14.w),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.vipGoldStart, AppColors.vipGoldEnd],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.vipGoldStart.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      size: 14,
                      color: Colors.black87,
                    ),
                    SizedBox(width: 3.w),
                    const Text(
                      'VIP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 860 : double.infinity,
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 16.w,
                  vertical: isDesktop ? 24 : 16.h,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Hero Header Card
                  _buildHeroHeader(isDesktop),
                  SizedBox(height: isDesktop ? 20 : 16.h),

                  // Employee Info Section
                  _buildSectionCard(
                    isDesktop: isDesktop,
                    title: 'معلومات حساب الموظف',
                    icon: Icons.badge_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Banner
                        Container(
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: AppColors.scafoldBackGround,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.lightGreyColor.withValues(alpha: 0.7),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24.r,
                                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.15),
                                child: Text(
                                  widget.employee.name.isNotEmpty
                                      ? widget.employee.name[0].toUpperCase()
                                      : 'E',
                                  style: TextStyle(
                                    fontSize: 18.sp,
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            widget.employee.name,
                                            style: TextStyles.customStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ),
                                        StatusBadge(
                                          statusKey: widget.employee.accountStatus,
                                          isEmployee: true,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      widget.employee.email,
                                      style: TextStyles.customStyle(
                                        fontSize: 12,
                                        color: AppColors.sandText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildFieldLabel('تعديل اسم الموظف'),
                        _buildInputField(
                          controller: _nameController,
                          hint: 'اسم الموظف',
                          icon: Icons.person_outline_rounded,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'اسم الموظف مطلوب';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isDesktop ? 20 : 16.h),

                  // Business Type & Role Presets Section
                  _buildSectionCard(
                    isDesktop: isDesktop,
                    title: 'القالب الوظيفي للصلاحيات',
                    icon: Icons.tune_rounded,
                    headerTrailing: Container(
                      decoration: BoxDecoration(
                        color: AppColors.scafoldBackGround,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppColors.lightGreyColor),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTypeSwitchChip('متجر / تجزئة', _isShop, () => _toggleBusinessType(true)),
                          _buildTypeSwitchChip('كافيه / بلايستيشن', !_isShop, () => _toggleBusinessType(false)),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اختر قالباً جاهزاً لتطبيق صلاحيات محددة مسبقاً تناسب طبيعة عمل الموظف:',
                          style: TextStyles.customStyle(
                            fontSize: 12,
                            color: AppColors.sandText,
                          ),
                        ),
                        SizedBox(height: isDesktop ? 14 : 12.h),
                        Wrap(
                          spacing: isDesktop ? 10 : 8.w,
                          runSpacing: isDesktop ? 10 : 8.h,
                          children: [
                            _buildPresetChip(
                              AppPermissions.roleCashier,
                              'كاشير (نقطة البيع)',
                              Icons.point_of_sale_rounded,
                              isDesktop: isDesktop,
                            ),
                            if (_isShop)
                              _buildPresetChip(
                                AppPermissions.roleStorekeeper,
                                'أمين مخزن ومشتريات',
                                Icons.inventory_2_outlined,
                                isDesktop: isDesktop,
                              ),
                            _buildPresetChip(
                              AppPermissions.roleAccountant,
                              'محاسب مالي',
                              Icons.calculate_outlined,
                              isDesktop: isDesktop,
                            ),
                            _buildPresetChip(
                              AppPermissions.roleSupervisor,
                              'مشرف عام للعمليات',
                              Icons.admin_panel_settings_outlined,
                              isDesktop: isDesktop,
                            ),
                            _buildPresetChip(
                              AppPermissions.roleCustom,
                              'مخصص',
                              Icons.tune_rounded,
                              isDesktop: isDesktop,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isDesktop ? 20 : 16.h),

                  // Granular Permissions Section
                  _buildSectionCard(
                    isDesktop: isDesktop,
                    title: 'الصلاحيات الممنوحة (${_selectedPermissions.length})',
                    icon: Icons.security_rounded,
                    headerTrailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: _selectAll,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 12 : 8.w,
                            ),
                          ),
                          child: Text(
                            'تحديد الكل',
                            style: TextStyles.customStyle(
                              fontSize: 12,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _deselectAll,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 12 : 8.w,
                            ),
                          ),
                          child: Text(
                            'إلغاء التحديد',
                            style: TextStyles.customStyle(
                              fontSize: 12,
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Search field for permissions
                        Container(
                          margin: EdgeInsets.only(bottom: 14.h),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val.trim()),
                            decoration: InputDecoration(
                              hintText: 'بحث في الصلاحيات والبنود...',
                              prefixIcon: Icon(Icons.search_rounded, size: 20.sp, color: AppColors.subTitleColor),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close_rounded, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: AppColors.scafoldBackGround,
                              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(color: AppColors.lightGreyColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(color: AppColors.lightGreyColor.withValues(alpha: 0.6)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(color: AppColors.primaryColor),
                              ),
                            ),
                          ),
                        ),

                        // Groups list
                        ...AppPermissions.getGroupsForBusinessType(isShop: _isShop).map((group) {
                          final visibleItems = group.items.where((item) {
                            if (_searchQuery.isEmpty) return true;
                            return item.titleAr.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                item.titleEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                item.key.toLowerCase().contains(_searchQuery.toLowerCase());
                          }).toList();

                          if (visibleItems.isEmpty) return const SizedBox.shrink();

                          final groupItemsCount = visibleItems.length;
                          final activeInGroup = visibleItems
                              .where((item) => _selectedPermissions.contains(item.key))
                              .length;

                          final isFull = activeInGroup == groupItemsCount && groupItemsCount > 0;
                          final isPartial = activeInGroup > 0 && activeInGroup < groupItemsCount;

                          return Container(
                            margin: EdgeInsets.only(bottom: isDesktop ? 12 : 10.h),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: isFull
                                    ? AppColors.primaryColor.withValues(alpha: 0.4)
                                    : isPartial
                                        ? AppColors.stitchOrange.withValues(alpha: 0.45)
                                        : AppColors.lightGreyColor.withValues(alpha: 0.7),
                                width: (isFull || isPartial) ? 1.5 : 1,
                              ),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                initiallyExpanded: _searchQuery.isNotEmpty,
                                leading: Container(
                                  padding: EdgeInsets.all(isDesktop ? 6 : 6.r),
                                  decoration: BoxDecoration(
                                    color: isFull
                                        ? AppColors.primaryColor.withValues(alpha: 0.12)
                                        : isPartial
                                            ? AppColors.stitchOrange.withValues(alpha: 0.12)
                                            : AppColors.lightGreyColor.withValues(alpha: 0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isFull
                                        ? Icons.check_circle_rounded
                                        : isPartial
                                            ? Icons.remove_circle_rounded
                                            : Icons.circle_outlined,
                                    color: isFull
                                        ? AppColors.primaryColor
                                        : isPartial
                                            ? AppColors.stitchOrange
                                            : AppColors.disabledColor,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  group.titleAr,
                                  style: TextStyles.customStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  '$activeInGroup / $groupItemsCount صلاحية',
                                  style: TextStyles.customStyle(
                                    fontSize: 11,
                                    color: isFull
                                        ? AppColors.primaryColor
                                        : isPartial
                                            ? AppColors.stitchOrange
                                            : AppColors.sandText,
                                    fontWeight: (isFull || isPartial)
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                                children: visibleItems.map((item) {
                                  final isChecked = _selectedPermissions.contains(item.key);
                                  final hasPrereqs = AppPermissions.hasPrerequisites(item.key);

                                  return CheckboxListTile(
                                    value: isChecked,
                                    onChanged: (_) => _togglePermission(item.key),
                                    title: Text(
                                      item.titleAr,
                                      style: TextStyles.customStyle(
                                        fontSize: 13,
                                        fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
                                        color: isChecked ? AppColors.black : AppColors.blackLight,
                                      ),
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
                                                  child: Text(
                                                    'تتطلب مسبقاً: ${AppPermissions.getPrerequisiteLabels(item.key)}',
                                                    style: TextStyles.customStyle(
                                                      fontSize: 10,
                                                      color: AppColors.sandText,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : null,
                                    activeColor: AppColors.primaryColor,
                                    dense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: isDesktop ? 20 : 16.w,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: isDesktop ? 28 : 24.h),

                  // Actions
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 500 : double.infinity,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              minimumSize: Size.fromHeight(isDesktop ? 55 : 55.h),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: isDesktop ? 22 : 22.h,
                                    width: isDesktop ? 22 : 22.h,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.save_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'حفظ التعديلات والصلاحيات',
                                          style: TextStyles.customStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          SizedBox(height: isDesktop ? 14 : 12.h),
                          OutlinedButton(
                            onPressed: _isLoading ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: isDesktop ? 16 : 14.h,
                              ),
                              side: BorderSide(color: AppColors.lightGreyColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: Text(
                              'إلغاء',
                              style: TextStyles.customStyle(
                                fontSize: 14,
                                color: AppColors.sandText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 20 : 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSwitchChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.blackLight,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.08),
            AppColors.primaryColor.withValues(alpha: 0.02),
          ],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 12 : 12.r),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.manage_accounts_rounded,
              color: AppColors.primaryColor,
              size: 26,
            ),
          ),
          SizedBox(width: isDesktop ? 16 : 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تعديل صلاحيات وحساب الموظف',
                  style: TextStyles.customStyle(
                    fontSize: isDesktop ? 16 : 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: isDesktop ? 4 : 3.h),
                Text(
                  'يمكنك إعادة تعيين الصلاحيات أو اختيار قالب وظيفي جديد للموظف مع حفظ جميع التعديلات فورياً.',
                  style: TextStyles.customStyle(
                    fontSize: isDesktop ? 13 : 12,
                    color: AppColors.sandText,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? headerTrailing,
    bool isDesktop = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.lightGreyColor.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (headerTrailing != null)
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8.w,
              runSpacing: 6.h,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isDesktop ? 6 : 6.r),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        icon,
                        size: 18,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(width: isDesktop ? 10 : 10.w),
                    Text(
                      title,
                      style: TextStyles.customStyle(
                        fontSize: isDesktop ? 16 : 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
                headerTrailing,
              ],
            )
          else
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isDesktop ? 6 : 6.r),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.primaryColor),
                ),
                SizedBox(width: isDesktop ? 10 : 10.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyles.customStyle(
                      fontSize: isDesktop ? 16 : 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          Divider(
            height: isDesktop ? 22 : 22.h,
            color: AppColors.lightGreyColor.withValues(alpha: 0.7),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildPresetChip(
    String presetKey,
    String label,
    IconData icon, {
    bool isDesktop = false,
  }) {
    final isSelected = _selectedPreset == presetKey;
    return ChoiceChip(
      showCheckmark: false,
      padding: isDesktop
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
          : null,
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : AppColors.primaryColor,
      ),
      label: Text(
        label,
        style: TextStyles.customStyle(
          fontSize: isDesktop ? 13 : 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppColors.black,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primaryColor,
      backgroundColor: AppColors.surface,
      onSelected: (_) => _applyPreset(presetKey),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: BorderSide(
          color: isSelected ? AppColors.primaryColor : AppColors.lightGreyColor,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixPressed,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
        fontSize: 14.sp,
        color: AppColors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 13.sp,
          color: AppColors.subTitleColor.withValues(alpha: 0.7),
        ),
        prefixIcon: Icon(icon, color: AppColors.primaryColor, size: 20.sp),
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon, size: 20.sp, color: AppColors.subTitleColor),
                onPressed: onSuffixPressed,
              )
            : null,
        filled: true,
        fillColor: AppColors.scafoldBackGround,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.lightGreyColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.lightGreyColor.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
