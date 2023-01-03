// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import 'package:msm/constants/constants.dart';

Widget saveButton({required void Function()? onPressed}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 25.h),
    child: IconButton(
      icon: Icon(
        FontAwesomeIcons.circleCheck,
        size: AppFontSizes.settingsSaveIconSize.sp,
      ),
      onPressed: onPressed,
    ),
  );
}

Future<PackageInfo> get appInfo async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo;
}
