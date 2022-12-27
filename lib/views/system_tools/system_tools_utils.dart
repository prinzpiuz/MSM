// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/font_sizes.dart';
import 'package:msm/views/ui_components/text/text.dart';
import 'package:msm/views/ui_components/text/textstyles.dart';

Widget systemToolTile(
    {required IconData icon,
    required String title,
    required String subtitle,
    required void Function() onTap}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 10.h),
    child: ListTile(
      dense: true,
      visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4),
      horizontalTitleGap: 20,
      leading: Icon(icon,
          color: CommonColors.commonBlackColor,
          size: AppFontSizes.systemToolsIcon.sp),
      title: AppText.singleLineText(title,
          style: AppTextStyles.bold(CommonColors.commonBlackColor,
              AppFontSizes.systemToolsTittleFontSize.sp)),
      subtitle: AppText.singleLineText(subtitle,
          style: AppTextStyles.medium(CommonColors.commonBlackColor,
              AppFontSizes.systemToolsSubtitleFontSize.sp)),
      onTap: onTap,
    ),
  );
}
