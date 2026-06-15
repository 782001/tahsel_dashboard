import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/config/locale/app_localizations.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String statusKey;

  const StatusBadge({super.key, required this.statusKey});

  Color get _color {
    switch (statusKey) {
      case 'active':
        return AppColors.success;
      case 'suspended':
        return AppColors.warning;
      case 'disabled':
      case 'deleted':
      case 'expired':
        return AppColors.error;
      case 'expiring_soon':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        AppLocalizations.tr('status_$statusKey'),
        style: TextStyle(
          color: _color,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
