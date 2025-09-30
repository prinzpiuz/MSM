// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/initialization.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/providers/file_listing_provider.dart';
import 'package:msm/providers/upload_provider.dart';
import 'package:msm/ui_components/text/text.dart';
import 'package:msm/ui_components/text/textstyles.dart';
// Project imports:
import 'package:msm/utils.dart';

Widget serverNotConnected(AppService appService, {bool text = true}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      IconButton(
          iconSize: AppFontSizes.notConnectedIconSize.sp,
          onPressed: () => Init.makeConnections(appService,
              wol: appService.server.serverFunctionsData.wakeOnLan),
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
          trackColor: const WidgetStatePropertyAll<Color>(Colors.grey),
          thumbColor: const WidgetStatePropertyAll<Color>(Colors.black),
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

PopupMenuButton commonPopUpMenu(
    {required void Function(dynamic) onSelected,
    required List menuListValues,
    required double size,
    dynamic disabledItem}) {
  return PopupMenuButton(
      icon: Icon(
        FontAwesomeIcons.ellipsisVertical,
        color: CommonColors.commonBlackColor,
        size: size.sp,
      ),
      onSelected: onSelected,
      itemBuilder: (BuildContext context) =>
          buildPopupMenus(menuListValues, disabledItem));
}

List<PopupMenuEntry> buildPopupMenus(
    List menuListValues, dynamic disabledItem) {
  List<PopupMenuEntry> menuList = [];
  for (var item in menuListValues) {
    menuList.add(PopupMenuItem(
        enabled: !(item == disabledItem),
        textStyle: item == disabledItem
            ? AppTextStyles.regular(CommonColors.commonGreenColor, 15.sp)
            : AppTextStyles.regular(CommonColors.commonBlackColor, 15.sp),
        value: item,
        child: AppText.text(item.menuText)));
  }
  return menuList;
}

void showMessage(
    {required BuildContext context,
    required String text,
    bool multiline = false,
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
              child: multiline
                  ? AppText.text(text)
                  : AppText.centerSingleLineText(text),
            ),
          ),
        ));
  });
  overlayState.insert(overlayEntry);
  await Future.delayed(Duration(seconds: duration));
  overlayEntry.remove();
}

Future<dynamic> dailogBox(
    {required BuildContext context,
    required String title,
    Widget? content,
    void Function()? okOnPressed,
    List<Widget>? actions,
    void Function()? cancelOnPressed,
    bool onlycancel = false}) {
  if (!onlycancel && okOnPressed == null) {
    okOnPressed = () => Navigator.pop(context, 'Ok');
  }
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
            dialogCancelButton(context),
            if (!onlycancel)
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

Future<String?> askPassword({required BuildContext context}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => AlertDialog(
      title: AppText.singleLineText("Enter Sudo Password",
          style: AppTextStyles.regular(CommonColors.commonBlackColor,
              AppFontSizes.dialogBoxTitleFontSize.sp)),
      content: TextField(
        autofocus: true,
        controller: controller,
        obscureText: true,
        obscuringCharacter: "*",
        style: const TextStyle(color: CommonColors.commonBlackColor),
        decoration: InputDecoration(
            hintText: "Sudo Password",
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: CommonColors.commonBlackColor,
              ),
            )),
      ),
      actions: <Widget>[
        dialogCancelButton(context),
        TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text("OK",
                style: AppTextStyles.regular(CommonColors.commonBlackColor,
                    AppFontSizes.dialogBoxactionFontSixe.sp))),
      ],
    ),
  );
}

OutlinedButton outlinedTextButton({
  required String text,
  required void Function() onPressed,
  Icon? icon,
}) {
  final buttonText = AppText.centerSingleLineText(text,
      style: AppTextStyles.bold(CommonColors.commonBlackColor, 12.sp));
  return OutlinedButton(
      style: ButtonStyle(
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0.r))),
          side: WidgetStateProperty.all(
              const BorderSide(color: CommonColors.commonBlackColor))),
      onPressed: onPressed,
      child: icon != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(
                  width: 10,
                ),
                buttonText,
              ],
            )
          : buttonText);
}
