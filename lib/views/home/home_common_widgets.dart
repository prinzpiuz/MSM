// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:msm/common_widgets.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/utils/commands/basic_details.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/ui_components/text/text.dart';
import 'package:msm/ui_components/text/textstyles.dart';

Widget homePageIcon(IconData icon,
    {bool fontAwesome = false, Color color = Colors.white}) {
  return fontAwesome
      ? FaIcon(icon, size: AppFontSizes.homePageIconFontSize.h, color: color)
      : Icon(icon, size: AppFontSizes.homePageIconFontSize.h, color: color);
}

List<Widget> homeIconList = [
  //order matters
  homePageIcon(Icons.cloud_upload_outlined),
  homePageIcon(FontAwesomeIcons.screwdriverWrench, fontAwesome: true),
  homePageIcon(Icons.folder_outlined),
  homePageIcon(Icons.settings),
];

Widget serverStats(IconData icon, String text) {
  return Padding(
    padding: EdgeInsets.only(right: 8.w),
    child: Wrap(
      spacing: 6.0, // gap between adjacent chips
      children: <Widget>[
        Icon(icon, size: 18.h, color: CommonColors.commonBlackColor),
        AppText.singleLineText(text,
            style: AppTextStyles.bold(CommonColors.commonBlackColor,
                AppFontSizes.serverStatFontSize.toDouble()))
      ],
    ),
  );
}

Widget serverDetails(BasicDetails? data) {
  if (data != null) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            homePageIcon(Icons.cloud, color: CommonColors.commonGreenColor),
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: AppText.centerSingleLineText(data.user,
                  style: AppTextStyles.bold(CommonColors.commonBlackColor,
                      AppFontSizes.serverStatFontSize)),
            )
          ],
        ),
        serverStats(
            FontAwesomeIcons.microchip, "${data.ram.used}/${data.ram.size}"),
        Padding(
          padding: EdgeInsets.only(top: 5.h, bottom: 5.h),
          child: serverStats(
              Icons.sd_card_outlined, "${data.disk.used}/${data.disk.size}"),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            serverStats(Icons.thermostat, data.tempreture),
            serverStats(Icons.alarm, data.uptime)
          ],
        )
      ],
    );
  }
  return commonCircularProgressIndicator;
}

Stream<BasicDetails> fetchBasicDetailsLive(
    StreamController<BasicDetails> controller, AppService appService) {
  late Timer timer;
  controller.onListen = () {
    timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (appService.connectionState) {
        BasicDetails? basicDetails =
            await appService.commandExecuter.basicDetails;
        if (basicDetails != null) {
          controller.add(basicDetails);
        } else {
          controller.close();
        }
      }
    });
  };
  controller.onCancel = () => timer.cancel();
  return controller.stream;
}
