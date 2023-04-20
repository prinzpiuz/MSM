// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/providers/file_listing_provider.dart';
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
    FileListingState? fileListState,
    bool pop = false}) {
  // to handle the backroutes of the app
  return WillPopScope(
    onWillPop: () async {
      if (backRoute != null) {
        handleBack(context, uploadState, fileListState, backRoute);
      }
      return pop;
    },
    child: child,
  );
}

void handleBack(BuildContext context, UploadState? uploadState,
    FileListingState? fileListState, String backRoute) {
  if (uploadState != null) {
    uploadState.commonCalls;
  }
  if (fileListState != null) {
    fileListState.popPath;
    fileListState.clearSelection;
    fileListState.setNextPage = fileListState.lastPage;
  }
  if (backRoute.isNotEmpty) {
    GoRouter.of(context).go(backRoute);
  }
}

PopupMenuButton commonPopUpMenu(
    {required void Function(dynamic) onSelected,
    required List menuListValues,
    required double size}) {
  return PopupMenuButton(
      icon: Icon(
        FontAwesomeIcons.ellipsisVertical,
        color: CommonColors.commonBlackColor,
        size: size.sp,
      ),
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => buildPopupMenus(menuListValues));
}

List<PopupMenuEntry> buildPopupMenus(List menuListValues) {
  List<PopupMenuEntry> menuList = [];
  for (var item in menuListValues) {
    menuList.add(PopupMenuItem(
      value: item,
      child: AppText.text(item.menuText,
          style: AppTextStyles.regular(CommonColors.commonBlackColor, 15.sp)),
    ));
  }
  return menuList;
}

void hideKeyboard(BuildContext ctx) {
  try {
    FocusManager.instance.primaryFocus?.unfocus();
  } catch (_) {}
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
        child: Container(
          height: 50.h,
          width: 60.w,
          color: CommonColors.commonWhiteColor,
          child: Center(
            child: DefaultTextStyle(
              style:
                  AppTextStyles.regular(CommonColors.commonBlackColor, 15.sp),
              child: AppText.centerSingleLineText(text),
            ),
          ),
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

String fileNameFromPath(String path) {
  return path.split('/').last.toString();
}
