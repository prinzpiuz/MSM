// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/font_sizes.dart';
import 'package:msm/providers/upload_provider.dart';
import 'package:msm/views/ui_components/text.dart';
import 'package:msm/views/ui_components/textstyles.dart';

WillPopScope handleBackButton(
    {String? backRoute,
    required Widget child,
    required BuildContext context,
    UploadState? uploadState,
    bool pop = false}) {
  // to handle the backroutes of the app
  return WillPopScope(
    onWillPop: () async {
      if (backRoute != null) {
        handleBack(context, uploadState, backRoute);
      }
      return pop;
    },
    child: child,
  );
}

PreferredSizeWidget commonAppBar(
    //common appbar for the project
    {required BuildContext context,
    bool send = false,
    String? text,
    UploadState? uploadState,
    List<Widget>? actions,
    required String backroute}) {
  const double appBarIconSIze = AppFontSizes.appBarIconSIze;
  EdgeInsetsGeometry appBarIconPadding = EdgeInsets.all(10.h);
  return AppBar(
    title: text != null
        ? AppText.singleLineText(text,
            style: AppTextStyles.bold(CommonColors.commonBlackColor,
                AppFontSizes.titleBarFontSize.sp))
        : const SizedBox(),
    elevation: 0,
    backgroundColor: CommonColors.commonWhiteColor,
    leading: Padding(
      padding: appBarIconPadding,
      child: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: CommonColors.commonBlackColor,
          size: appBarIconSIze,
        ),
        onPressed: () => handleBack(context, uploadState, backroute),
      ),
    ),
    actions: actions,
  );
}

Widget get commonCircularProgressIndicator => const Center(
        child: CircularProgressIndicator(
      color: CommonColors.commonGreenColor,
    ));

void handleBack(
    BuildContext context, UploadState? uploadState, String backRoute) {
  if (uploadState != null) {
    uploadState.popLastDirectory();
  }
  GoRouter.of(context).go(backRoute);
}
