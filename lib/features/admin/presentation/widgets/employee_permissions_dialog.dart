import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/constants/app_rbac_catalog.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
import 'package:tahsel_dashboard/core/utils/styles.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/tenant_employee.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';

class EmployeePermissionsDialog extends StatelessWidget {
  final TenantEmployee employee;

  const EmployeePermissionsDialog({super.key, required this.employee});

  static Future<void> show(BuildContext context, TenantEmployee employee) {
    return showDialog(
      context: context,
      builder: (_) => EmployeePermissionsDialog(employee: employee),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAll = employee.permissions.contains('*');
    final activeCount =
        hasAll ? AppRbacCatalog.totalPermissions : employee.permissions.length;

    return AlertDialog(
      backgroundColor: AppColors.scafoldBackGround,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      titlePadding: EdgeInsets.all(16.w),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      actionsPadding: EdgeInsets.all(12.w),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
            child: Text(
              employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '؟',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  employee.name,
                  style: TextStyles.appbartext().copyWith(fontSize: 16.sp),
                ),
                SizedBox(height: 2.h),
                TextWidget(
                  employee.email,
                  style: TextStyles.font14Weight400RightAligned().copyWith(
                    color: AppColors.subTitleColor,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: employee.isActive
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: TextWidget(
              employee.isActive
                  ? 'status_active'.tr()
                  : 'status_suspended'.tr(),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: employee.isActive ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: math.min(540.w, MediaQuery.of(context).size.width * 0.95),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.primaryColor, size: 20.sp),
                      SizedBox(width: 8.w),
                      TextWidget(
                        'دور الموظف: ${_getRoleLabel(employee.rolePreset)}',
                        style: TextStyles.font14Weight400RightAligned().copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextWidget(
                    'الصلاحيات: $activeCount من ${AppRbacCatalog.totalPermissions}',
                    style: TextStyles.font14Weight400RightAligned().copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: AppRbacCatalog.groups.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final group = AppRbacCatalog.groups[index];
                  final grantedInGroup = group.items.where(
                    (item) => hasAll || employee.permissions.contains(item.key),
                  ).length;

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: grantedInGroup > 0
                            ? AppColors.primaryColor.withValues(alpha: 0.25)
                            : Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: grantedInGroup > 0,
                        tilePadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
                        title: Row(
                          children: [
                            Expanded(
                              child: TextWidget(
                                group.titleAr,
                                style: TextStyles.font14Weight400RightAligned().copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: grantedInGroup == group.items.length
                                    ? AppColors.success.withValues(alpha: 0.12)
                                    : grantedInGroup > 0
                                        ? Colors.orange.withValues(alpha: 0.12)
                                        : Colors.grey.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: TextWidget(
                                '$grantedInGroup / ${group.items.length}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: grantedInGroup == group.items.length
                                      ? AppColors.success
                                      : grantedInGroup > 0
                                          ? Colors.orange
                                          : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        children: group.items.map((item) {
                          final bool isGranted =
                              hasAll || employee.permissions.contains(item.key);
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                            child: Row(
                              children: [
                                Icon(
                                  isGranted
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_outlined,
                                  size: 18.sp,
                                  color: isGranted ? AppColors.success : Colors.grey[400],
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: TextWidget(
                                    item.titleAr,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: isGranted ? Colors.black87 : Colors.grey[500],
                                      fontWeight: isGranted ? FontWeight.w500 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                TextWidget(
                                  item.key,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontFamily: 'monospace',
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: TextWidget('cancel'.tr()),
        ),
      ],
    );
  }

  String _getRoleLabel(String preset) {
    switch (preset) {
      case 'cashier':
        return 'كاشير (نقطة البيع)';
      case 'storekeeper':
        return 'أمين مخزن ومشتريات';
      case 'accountant':
        return 'محاسب مالي';
      case 'supervisor':
        return 'مشرف عام للعمليات';
      case 'custom':
        return 'مخصص';
      default:
        return preset;
    }
  }
}
