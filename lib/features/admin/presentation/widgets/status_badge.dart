import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/config/locale/app_localizations.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String statusKey;
  final bool isEmployee;

  const StatusBadge({
    super.key,
    required this.statusKey,
    this.isEmployee = false,
  });

  String get _effectiveKey {
    if (isEmployee) {
      if (statusKey == 'expired' || statusKey == 'expiring_soon') {
        return 'disabled';
      }
    }
    return statusKey;
  }

  Color get _color {
    switch (_effectiveKey) {
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
      case 'platform_type_mobile':
      case 'platform_type_desktop':
      case 'platform_type_both':
        return AppColors.primaryColor;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final key = _effectiveKey;
    final textKey = key.startsWith('platform_type_') ? key : 'status_$key';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        AppLocalizations.tr(textKey),
        style: TextStyle(
          color: _color,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
