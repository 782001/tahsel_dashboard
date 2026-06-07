import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/config/locale/app_localizations.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
import 'package:tahsel_dashboard/shared/widgets/toast/custom_toast.dart' show showSuccessToast;

class CopyButton extends StatelessWidget {
  final String text;
  final String tostText;

  const CopyButton({super.key, required this.text
      , this.tostText = 'uid_copied'});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppLocalizations.tr('copy_uid'),
      icon: Icon(Icons.copy, size: 20.sp, color: AppColors.primaryColor),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: text));
        showSuccessToast(AppLocalizations.tr(tostText));
      },
    );
  }
}
