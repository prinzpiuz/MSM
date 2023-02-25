// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/models/folder_configuration.dart';
import 'package:msm/models/server_details.dart';
import 'package:msm/models/server_functions.dart';
import 'package:msm/models/storage.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/providers/folder_configuration_provider.dart';
import 'package:msm/ui_components/text/text.dart';
import 'package:msm/ui_components/text/textstyles.dart';
import 'package:msm/ui_components/textfield/textfield.dart';
import 'package:msm/ui_components/textfield/validators.dart';

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

void saveServerDetails(
    GlobalKey<FormState> formKey, ServerData serverData, BuildContext context) {
  hideKeyboard(context);
  if (formKey.currentState!.validate()) {
    formKey.currentState!.save();
    Provider.of<AppService>(context, listen: false)
        .storage
        .saveObject(StorageKeys.serverData.key, serverData);
    Provider.of<AppService>(context, listen: false).updateServerDetails =
        serverData;
    showMessage(context: context, text: AppMessages.serverDetailSaved);
  }
}

void saveServerFunctions(
  ServerFunctionsData serverFunctionsData,
  BuildContext context,
) {
  Provider.of<AppService>(context, listen: false)
      .storage
      .saveObject(StorageKeys.serverFunctions.key, serverFunctionsData);
  Provider.of<AppService>(context, listen: false).updateServerFunctions =
      serverFunctionsData;
  showMessage(context: context, text: AppMessages.serverFunctionSaved);
}

void saveFolderConfigurations(GlobalKey<FormState> formKey,
    FolderConfiguration folderConfiguration, BuildContext context) {
  hideKeyboard(context);
  Provider.of<FolderConfigState>(context, listen: false).resetFolderCount();
  if (formKey.currentState!.validate()) {
    formKey.currentState!.save();
    Provider.of<AppService>(context, listen: false)
        .storage
        .saveObject(StorageKeys.folderConfigurations.key, folderConfiguration);
    Provider.of<AppService>(context, listen: false).updateFolderConfigurations =
        folderConfiguration;
    showMessage(context: context, text: AppMessages.folderConfigurationSaved);
  }
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
                borderRadius: BorderRadius.circular(30.0.r))),
            side: MaterialStateProperty.all(
                const BorderSide(color: CommonColors.commonBlackColor))),
        onPressed: onPressed,
        child: AppText.centerSingleLineText("Add Custom Path",
            style: AppTextStyles.bold(CommonColors.commonBlackColor, 12.sp))),
  );
}

void getFoldersList(
  BuildContext context,
  FolderConfiguration folderConfiguration,
  GlobalKey<FormState> formKey,
) {
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
        initialValue: folderConfiguration.customFolders[i],
        keyboardType: TextInputType.text,
        labelText: "Custom",
        hintText: "Custom Folder",
        suffix: true,
        onSuffixIconPressed: () => {
          folderConfiguration.removeExtraFolder(i),
          saveFolderConfigurations(formKey, folderConfiguration, context),
          Provider.of<FolderConfigState>(context, listen: false)
              .removeFromWidgetList(3 + i)
        },
      ));
    }
  }
  if (folderConfigState.addNewPath) {
    for (int j = 0; j < folderConfigState.foldersCount; j++) {
      folders.add(AppTextField.commonTextFeild(
        onsaved: (data) {
          folderConfiguration.addExtraFolder(data);
        },
        validator: valueNeeded,
        keyboardType: TextInputType.text,
        labelText: "Custom Folder",
        hintText: "Path To Your Custom Folder",
        suffix: true,
        onSuffixIconPressed: () => {
          Provider.of<FolderConfigState>(context, listen: false)
              .removeFromWidgetList(
                  3 + folderConfiguration.customFolders.length + j)
        },
      ));
    }

    folderConfigState.addNewPath = false;
  }

  folders.add(addCustomPathButton(onPressed: () {
    saveFolderConfigurations(formKey, folderConfiguration, context);
    Provider.of<FolderConfigState>(context, listen: false).setAddNewPath = true;
    Provider.of<FolderConfigState>(context, listen: false)
        .incrementFolderCount();
  }));
  folderConfigState.pathTextFields = folders;
}
