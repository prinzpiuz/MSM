// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/ui_components/text/text.dart';
import 'package:msm/ui_components/text/textstyles.dart';
import 'package:msm/views/settings/settings_utils.dart';

class AppInfo extends StatelessWidget {
  const AppInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return appDetails(context);
  }
}

Widget appDetails(BuildContext context) {
  return Scaffold(
      appBar: commonAppBar(
          backroute: Pages.settings.toPath,
          context: context,
          text: SettingsSubRoute.appInfo.toTitle),
      backgroundColor: CommonColors.commonWhiteColor,
      body: Center(
        child: FutureBuilder<PackageInfo>(
          future: appInfo,
          builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: snapshot.hasData
                      ? dataWidget(data: snapshot.data)
                      : snapshot.hasError
                          ? errorWidget
                          : loadingWidget,
                ),
                links
              ],
            );
          },
        ),
      ));
}

List<Widget> dataWidget({required PackageInfo? data}) {
  return [
    SvgPicture.asset(
      AppConstants.appIconImageLocation,
      height: AppConstants.appInfoIconHeight.h,
      width: AppConstants.appInfoIconWidth.w,
    ),
    AppText.centerSingleLineText(data!.appName.toUpperCase(),
        style: AppTextStyles.medium(CommonColors.commonBlackColor,
            AppFontSizes.appShortNameFontSize.sp)),
    AppText.centerSingleLineText(AppConstants.appFullName,
        style: AppTextStyles.medium(CommonColors.commonBlackColor,
            AppFontSizes.appLongNameFontSize.sp)),
    AppText.centerSingleLineText("${data.version}.${data.buildNumber}",
        style: AppTextStyles.medium(CommonColors.commonBlackColor,
            AppFontSizes.appLongNameFontSize.sp)),
  ];
}

Widget get links => Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 1.5,
        direction: Axis.vertical,
        children: [
          InkWell(
              child: AppText.centerSingleLineText(AppConstants.homPage,
                  style: linkStyle),
              onTap: () => launchUrl(Uri.parse(AppConstants.homePageUrl))),
          InkWell(
              child: AppText.centerSingleLineText(AppConstants.license,
                  style: linkStyle),
              onTap: () => launchUrl(Uri.parse(AppConstants.licenseUrl))),
          InkWell(
              child: AppText.centerSingleLineText(
                  AppConstants.appIssueFeatureReport,
                  style: linkStyle),
              onTap: () => launchUrl(Uri.parse(AppConstants.issueReportUrl)))
        ]);

List<Widget> get errorWidget => [
      Icon(
        Icons.error_outline,
        color: Colors.red,
        size: 60.sp,
      ),
      Padding(
        padding: EdgeInsets.only(top: 16.h),
        child: const Text('Error!'),
      ),
    ];

List<Widget> get loadingWidget => [
      SizedBox(
        width: 60.w,
        height: 60.h,
        child: commonCircularProgressIndicator,
      ),
    ];

TextStyle get linkStyle => AppTextStyles.medium(
    CommonColors.commonLinkColor, AppFontSizes.appInfoLinkFontSize.sp);
