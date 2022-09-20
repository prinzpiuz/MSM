// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/font_sizes.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/views/ui_components/text.dart';
import 'package:msm/views/ui_components/textstyles.dart';

WillPopScope handleBackButton(
    {String? backRoute,
    required Widget child,
    required BuildContext context,
    bool pop = false}) {
  return WillPopScope(
    onWillPop: () async {
      if (backRoute != null) {
        GoRouter.of(context).go(backRoute);
      }
      return pop;
    },
    child: child,
  );
}

PreferredSizeWidget commonAppBar(
    {required BuildContext context, bool send = false, String? text}) {
  const Color appBarIconColor = CommonColors.commonBlackColor;
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
        onPressed: () => GoRouter.of(context).go(Pages.upload.toPath),
      ),
    ),
    actions: [
      Padding(
        padding: appBarIconPadding,
        child: IconButton(
            onPressed: (() => debugPrint("sending")),
            icon: const Icon(
              Icons.send_outlined,
              color: appBarIconColor,
              size: appBarIconSIze,
            )),
      )
    ],
  );
}

Widget get commonCircularProgressIndicator => const Center(
        child: CircularProgressIndicator(
      color: CommonColors.commonGreenColor,
    ));
