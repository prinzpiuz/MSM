// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/providers/upload_provider.dart';
import 'package:msm/ui_components/text/text.dart';
import 'package:msm/ui_components/text/textstyles.dart';

bool get appENV {
  bool isProd = const bool.fromEnvironment('dart.vm.product');
  return isProd;
}

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

void handleBack(
    BuildContext context, UploadState? uploadState, String backRoute) {
  if (uploadState != null) {
    uploadState.commonCalls;
  }
  GoRouter.of(context).go(backRoute);
}

PopupMenuButton commonPopUpMenu(List menuListValues) {
  return PopupMenuButton(
      icon: Icon(
        FontAwesomeIcons.ellipsisVertical,
        color: CommonColors.commonBlackColor,
        size: AppFontSizes.appBarIconSize.sp,
      ),
      onSelected: (dynamic item) {},
      itemBuilder: (BuildContext context) => buildPopupMenus(menuListValues));
}

List<PopupMenuEntry> buildPopupMenus(List menuListValues) {
  List<PopupMenuEntry> menuList = [];
  for (var item in menuListValues) {
    menuList.add(PopupMenuItem(
      value: item,
      child: Text(item.menuText),
    ));
  }
  return menuList;
}

void hideKeyboard(BuildContext ctx) {
  try {
    FocusManager.instance.primaryFocus?.unfocus();
  } catch (e) {
    //
  }
}

void showMessage(
    {required BuildContext context,
    required String text,
    int duration = 3}) async {
  OverlayState overlayState = Overlay.of(context);
  OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
    return Positioned(
        bottom: 100.h,
        left: 40.h,
        right: 40.h,
        child: DefaultTextStyle(
          style: AppTextStyles.regular(CommonColors.commonBlackColor, 15.sp),
          child: AppText.centerSingleLineText(text),
        ));
  });
  overlayState.insert(overlayEntry);
  await Future.delayed(Duration(seconds: duration));
  overlayEntry.remove();
}

Future<dynamic> dailogBox({
  required BuildContext context,
  required String title,
  Widget? content,
  required void Function() okOnPressed,
  List<Widget>? actions,
  void Function()? cancelOnPressed,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => AlertDialog(
      title: AppText.singleLineText(title,
          style: AppTextStyles.regular(CommonColors.commonBlackColor,
              AppFontSizes.dialogBoxTitleFontSize.sp)),
      content: content,
      actions: actions ??
          <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: Text('Cancel',
                  style: AppTextStyles.regular(CommonColors.commonBlackColor,
                      AppFontSizes.dialogBoxactionFontSixe.sp)),
            ),
            TextButton(
              onPressed: okOnPressed,
              child: Text('OK',
                  style: AppTextStyles.regular(CommonColors.commonBlackColor,
                      AppFontSizes.dialogBoxactionFontSixe.sp)),
            ),
          ],
    ),
  );
}
