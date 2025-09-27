// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:msm/common_widgets.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/ui_components/text/text.dart';
import 'package:msm/ui_components/text/textstyles.dart';
import 'package:msm/utils/commands/basic_details.dart';
import 'package:msm/utils/commands/command_executer.dart';

Future<dynamic> speedTestOutput(BuildContext context) {
  return dailogBox(
      onlycancel: true,
      context: context,
      title: "Speed Test",
      content: SizedBox(height: 130.h, child: speedTester(context)));
}

Widget speedTester(BuildContext context) {
  final AppService appService = Provider.of<AppService>(context, listen: false);
  final bool connected = appService.connectionState;
  CommandExecuter commandExecuter = appService.commandExecuter;
  final Future<dynamic> speed = commandExecuter.speedTest();
  if (connected) {
    return FutureBuilder(
        future: speed,
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data != null) {
            if (snapshot.data.runtimeType == Speed) {
              return speedData(snapshot.data!);
            }
            return AppText.text(snapshot.data!,
                style: AppTextStyles.regular(
                    CommonColors.commonBlackColor, 15.sp));
          } else if (snapshot.hasError) {
            return Center(child: serverNotConnected(appService, text: false));
          } else {
            return commonCircularProgressIndicator;
          }
        });
  } else {
    return Center(child: serverNotConnected(appService, text: false));
  }
}

Widget speedData(Speed speedData) {
  return SingleChildScrollView(
    child: Column(
      children: [
        AppText.centerSingleLineText("Download",
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.noFilesFontSize.sp)),
        AppText.centerSingleLineText(speedData.downloadSpeed,
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.noFilesFontSize.sp)),
        AppText.centerSingleLineText("Upload",
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.noFilesFontSize.sp)),
        AppText.centerSingleLineText(speedData.uploadSpeed,
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.noFilesFontSize.sp)),
        AppText.centerSingleLineText("ISP",
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.noFilesFontSize.sp)),
        AppText.centerSingleLineText(speedData.isp,
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.noFilesFontSize.sp)),
        AppText.centerSingleLineText("Ping",
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.noFilesFontSize.sp)),
        AppText.centerSingleLineText(speedData.ping,
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.noFilesFontSize.sp)),
        AppText.centerSingleLineText("Country",
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.noFilesFontSize.sp)),
        AppText.centerSingleLineText(speedData.country,
            style: AppTextStyles.regular(
                CommonColors.commonBlackColor, AppFontSizes.noFilesFontSize.sp))
      ],
    ),
  );
}
