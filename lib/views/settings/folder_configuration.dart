// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/views/settings/settings_utils.dart';
import 'package:msm/views/ui_components/text/text.dart';
import 'package:msm/views/ui_components/text/textstyles.dart';
import 'package:msm/views/ui_components/textfield/textfield.dart';

class FolderConfiguration extends StatefulWidget {
  const FolderConfiguration({super.key});

  @override
  State<FolderConfiguration> createState() => _FolderConfigurationState();
}

class _FolderConfigurationState extends State<FolderConfiguration> {
  @override
  Widget build(BuildContext context) {
    return folderConfigurationForm(context);
  }
}

Widget folderConfigurationForm(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  return Scaffold(
      appBar: commonAppBar(
          backroute: Pages.settings.toPath,
          context: context,
          text: SettingsSubRoute.folderConfiguration.toTitle),
      backgroundColor: CommonColors.commonWhiteColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: saveButton(
        onPressed: () => print("save"),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            AppTextField.commonTextFeild(
              onsaved: (data) {
                print(data);
              },
              keyboardType: TextInputType.text,
              labelText: "Movies",
              hintText: "Path To Your Movies Folder",
            ),
            AppTextField.commonTextFeild(
              onsaved: (data) {
                print(data);
              },
              keyboardType: TextInputType.number,
              labelText: "TV Shows",
              hintText: "Path To Your Movies Folder",
            ),
            AppTextField.commonTextFeild(
                onsaved: (data) {
                  print(data);
                },
                keyboardType: TextInputType.visiblePassword,
                labelText: "Images",
                hintText: "Path To Your Images Folder"),
            addCustomPathButton(onPressed: () {})
          ],
        ),
      ));
}

Widget addCustomPathButton({required void Function()? onPressed}) {
  return Padding(
    padding: EdgeInsets.only(top: 20.h, left: 18.w, right: 18.w),
    child: OutlinedButton(
        style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0))),
            side: MaterialStateProperty.all(
                const BorderSide(color: CommonColors.commonBlackColor))),
        onPressed: onPressed,
        child: AppText.centerSingleLineText("Add Custom Path",
            style: AppTextStyles.bold(CommonColors.commonBlackColor, 12.sp))),
  );
}
