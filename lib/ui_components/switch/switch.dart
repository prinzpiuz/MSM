// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/ui_components/text/text.dart';
import 'package:msm/ui_components/text/textstyles.dart';

class CommonSwitch extends StatefulWidget {
  final String text;
  final bool value;
  final ValueChanged<bool> onChanged;
  const CommonSwitch(
      {super.key,
      required this.text,
      required this.onChanged,
      required this.value});

  @override
  State<CommonSwitch> createState() => _CommonSwitchState();
}

class _CommonSwitchState extends State<CommonSwitch> {
  bool initial = true;
  late bool switchValue;
  @override
  Widget build(BuildContext context) {
    if (initial) {
      switchValue = widget.value;
      initial = false;
    }
    return Padding(
      padding: EdgeInsets.only(left: 18.w, right: 18.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText.singleLineText(widget.text,
              style: AppTextStyles.medium(CommonColors.commonBlackColor,
                  AppFontSizes.systemToolsTittleFontSize.sp)),
          Switch(
            value: switchValue,
            trackColor: const WidgetStatePropertyAll<Color>(Colors.grey),
            thumbColor: const WidgetStatePropertyAll<Color>(Colors.black),
            onChanged: (value) {
              setState(() {
                switchValue = value;
                widget.onChanged(value);
              });
            },
          )
        ],
      ),
    );
  }
}
