import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/config/locale/app_localizations.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
import 'package:tahsel_dashboard/shared/widgets/toast/custom_toast.dart' show showSuccessToast;

class CopyUidButton extends StatelessWidget {
  final String uid;

  const CopyUidButton({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppLocalizations.tr('copy_uid'),
      icon: Icon(Icons.copy, size: 20.sp, color: AppColors.primaryColor),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: uid));
        showSuccessToast(AppLocalizations.tr('uid_copied'));
      },
    );
  }
}
