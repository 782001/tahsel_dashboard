import 'package:flutter/material.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';

Future<int?> showCustomDaysDialog(
  BuildContext context, {
  String? titleKey,
  int initialDays = 30,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) =>
        _CustomDaysDialog(titleKey: titleKey, initialDays: initialDays),
  );
}

class _CustomDaysDialog extends StatefulWidget {
  final String? titleKey;
  final int initialDays;

  const _CustomDaysDialog({this.titleKey, required this.initialDays});

  @override
  State<_CustomDaysDialog> createState() => _CustomDaysDialogState();
}

class _CustomDaysDialogState extends State<_CustomDaysDialog> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialDays.toString());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextWidget(widget.titleKey?.tr() ?? 'admin_custom_duration'.tr()),
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
          onPressed: () => Navigator.pop(context),
          child: TextWidget('cancel'.tr()),
        ),
        TextButton(
          onPressed: () {
            final days = int.tryParse(controller.text.trim());
            if (days != null && days > 0) {
              Navigator.pop(context, days);
            }
          },
          child: TextWidget('confirm'.tr()),
        ),
      ],
    );
  }
}
