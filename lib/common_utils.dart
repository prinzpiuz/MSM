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
  double appBarIconSIze = AppFontSizes.appBarIconSize.sp;
  EdgeInsetsGeometry appBarIconPadding = EdgeInsets.all(10.h);
  return AppBar(
    title: text != null
        ? AppText.singleLineText(text,
            style: AppTextStyles.medium(CommonColors.commonBlackColor,
                AppFontSizes.titleBarFontSize.sp))
        : const SizedBox(),
    elevation: AppConstants.appBarElevation,
    backgroundColor: CommonColors.commonWhiteColor,
    leading: Padding(
      padding: appBarIconPadding,
      child: IconButton(
        icon: Icon(
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
    int duration = 8}) async {
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
