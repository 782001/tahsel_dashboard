import 'package:flutter/material.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';

Future<int?> showCustomDaysDialog(
  BuildContext context, {
  String? titleKey,
  int initialDays = 30,
}) async {
  final controller = TextEditingController(text: '$initialDays');
  final result = await showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: TextWidget(titleKey?.tr() ?? 'admin_custom_duration'.tr()),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'admin_subscription_days'.tr(),
          suffixText: 'admin_days'.tr(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: TextWidget('cancel'.tr()),
        ),
        TextButton(
          onPressed: () {
            final days = int.tryParse(controller.text.trim());
            if (days != null && days > 0) Navigator.pop(ctx, days);
          },
          child: TextWidget('confirm'.tr()),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}
