// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/initialization.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/providers/file_listing_provider.dart';
import 'package:msm/providers/upload_provider.dart';
import 'package:msm/ui_components/text/text.dart';
import 'package:msm/ui_components/text/textstyles.dart';

Widget serverNotConnected(AppService appService, {bool text = true}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      IconButton(
          iconSize: AppFontSizes.notConnectedIconSize.sp,
          onPressed: () => Init.makeConnections(appService),
          icon: const Icon(
            Icons.cloud_off,
            color: CommonColors.commonGreyColor,
            // size: 90.sp,
          )),
      text
          ? AppText.singleLineText(appService.server.state.message,
              style: AppTextStyles.regular(CommonColors.commonBlackColor,
                  AppFontSizes.notConnectedFontSize.sp))
          : const SizedBox()
    ],
  );
}

EdgeInsetsGeometry get commonListViewTopPadding => EdgeInsets.only(top: 10.h);

Widget commonSwitch(
    {required String text,
    required bool value,
    required Function(bool)? onChange}) {
  return Padding(
    padding: EdgeInsets.only(left: 18.w, right: 18.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText.singleLineText(text,
            style: AppTextStyles.medium(CommonColors.commonBlackColor,
                AppFontSizes.systemToolsTittleFontSize.sp)),
        Switch(
          value: value,
          trackColor: const MaterialStatePropertyAll<Color>(Colors.grey),
          thumbColor: const MaterialStatePropertyAll<Color>(Colors.black),
          onChanged: onChange,
        )
      ],
    ),
  );
}

Widget commonTile(
    {required IconData icon,
    required String title,
    String? subtitle,
    required void Function() onTap}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 10.h),
    child: ListTile(
      visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4),
      horizontalTitleGap: 20,
      leading: Icon(icon,
          color: CommonColors.commonBlackColor,
          size: AppFontSizes.systemToolsIcon.sp),
      title: AppText.singleLineText(title,
          style: AppTextStyles.regular(CommonColors.commonBlackColor,
              AppFontSizes.systemToolsTittleFontSize.sp)),
      subtitle: AppText.singleLineText(subtitle ?? "",
          style: AppTextStyles.regular(CommonColors.commonBlackColor,
              AppFontSizes.systemToolsSubtitleFontSize.sp)),
      onTap: onTap,
    ),
  );
}

Widget get commonCircularProgressIndicator => const Center(
        child: CircularProgressIndicator(
      color: CommonColors.commonGreenColor,
    ));

PreferredSizeWidget commonAppBar(
    //common appbar for the project
    {required BuildContext context,
    bool send = false,
    String? text,
    UploadState? uploadState,
    FileListingState? fileListState,
    List<Widget>? actions,
    required String backroute}) {
  double appBarIconSIze = AppFontSizes.appBarIconSize.sp;
  EdgeInsetsGeometry appBarIconPadding =
      EdgeInsets.only(left: 10.w, right: 10.w);
  return AppBar(
    title: text != null
        ? AppText.singleLineText(text,
            style: AppTextStyles.medium(CommonColors.commonBlackColor,
                AppFontSizes.titleBarFontSize.sp))
        : const SizedBox(),
    elevation: AppMeasurements.appBarElevation,
    backgroundColor: CommonColors.commonWhiteColor,
    leading: Padding(
      padding: appBarIconPadding,
      child: IconButton(
        iconSize: appBarIconSIze,
        icon: const Icon(
          Icons.arrow_back,
          color: CommonColors.commonBlackColor,
        ),
        onPressed: () =>
            handleBack(context, uploadState, fileListState, backroute),
      ),
    ),
    actions: actions,
  );
}

Widget get commonDivider => const Divider(
      color: CommonColors.commonBlackColor,
    );

Widget dialogCancelButton(BuildContext context) => TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text('Cancel',
          style: AppTextStyles.regular(CommonColors.commonBlackColor,
              AppFontSizes.dialogBoxactionFontSixe.sp)),
    );
