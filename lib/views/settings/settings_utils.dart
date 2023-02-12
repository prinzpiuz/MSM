// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/models/folder_configuration.dart';
import 'package:msm/providers/folder_configuration_provider.dart';
import 'package:msm/views/ui_components/text/text.dart';
import 'package:msm/views/ui_components/text/textstyles.dart';
import 'package:msm/views/ui_components/textfield/textfield.dart';
import 'package:msm/views/ui_components/textfield/validators.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import 'package:msm/constants/constants.dart';
import 'package:msm/models/server_details.dart';
import 'package:msm/models/server_functions.dart';
import 'package:msm/models/storage.dart';
import 'package:provider/provider.dart';

Widget saveButton({required void Function()? onPressed}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 25.h),
    child: IconButton(
      icon: Icon(
        FontAwesomeIcons.circleCheck,
        size: AppFontSizes.settingsSaveIconSize.sp,
      ),
      onPressed: onPressed,
    ),
  );
}

void saveServerDetails(GlobalKey<FormState> formKey, ServerData serverData) {
  if (formKey.currentState!.validate()) {
    formKey.currentState!.save();
    Storage().saveObject(StorageKeys.serverData.key, serverData);
    //TODO implement toast messages
  }
}

void saveServerFunctions(ServerFunctionsData serverFunctionsData) {
  print(serverFunctionsData);
  Storage().saveObject(StorageKeys.serverFunctions.key, serverFunctionsData);
  //TODO implement toast messages
}

void saveFolderConfigurations(FolderConfiguration folderConfiguration) {
  Storage()
      .saveObject(StorageKeys.folderConfigurations.key, folderConfiguration);
  //TODO implement toast messages
}

Future<PackageInfo> get appInfo async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo;
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

List<Widget> getFoldersList(
    BuildContext context, FolderConfiguration folderConfiguration) {
  FolderConfigState folderConfigState = Provider.of<FolderConfigState>(context);
  List<Widget> folders = [
    AppTextField.commonTextFeild(
      onsaved: (data) {
        folderConfiguration.movies = data;
      },
      initialValue: folderConfiguration.movies,
      keyboardType: TextInputType.text,
      labelText: "Movies",
      hintText: "Path To Your Movies Folder",
    ),
    AppTextField.commonTextFeild(
      onsaved: (data) {
        folderConfiguration.tv = data;
      },
      initialValue: folderConfiguration.tv,
      keyboardType: TextInputType.text,
      labelText: "TV Shows",
      hintText: "Path To Your Movies Folder",
    ),
    AppTextField.commonTextFeild(
        onsaved: (data) {
          folderConfiguration.books = data;
        },
        initialValue: folderConfiguration.books,
        keyboardType: TextInputType.text,
        labelText: "E-Books",
        hintText: "Path To Your E-Books Folder"),
  ];
  if (folderConfiguration.customFolders.isNotEmpty) {
    for (int i = 0; i < folderConfiguration.customFolders.length; i++) {
      folders.add(AppTextField.commonTextFeild(
        onsaved: (data) {},
        initialValue: folderConfiguration.customFolders[i],
        keyboardType: TextInputType.text,
        labelText: "Custom",
        hintText: "Custom Folder",
        suffix: true,
        onSuffixIconPressed: () => {print("saved delete")},
      ));
    }
  }
  if (folderConfigState.addNewPath) {
    for (int i = 0; i < folderConfigState.foldersCount; i++) {
      folders.add(AppTextField.commonTextFeild(
        onsaved: (data) {
          folderConfiguration.addExtraFolder(data);
        },
        validator: valueNeeded,
        keyboardType: TextInputType.text,
        labelText: "Custom Folder",
        hintText: "Path To Your Custom Folder",
        suffix: true,
        onSuffixIconPressed: () => {print("saved delete")},
      ));
    }

    Provider.of<FolderConfigState>(context).addNewPath = false;
  }

  folders.add(addCustomPathButton(onPressed: () {
    Provider.of<FolderConfigState>(context, listen: false).setaddNewPath = true;
    Provider.of<FolderConfigState>(context, listen: false)
        .incrementFolderCount();
  }));
  return folders;
}
