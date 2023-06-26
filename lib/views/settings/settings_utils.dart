// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/common_widgets.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/models/folder_configuration.dart';
import 'package:msm/models/send_to_kindle.dart';
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

String generateFolderConfigurationNotSavedMessage(List<String> folders) {
  String msg = "Folder Configuration Not Saved\n";
  String notSavedFolders = "These Folders Not Exist\n";
  for (String folder in folders) {
    notSavedFolders += "$folder\n";
  }
  return msg + notSavedFolders;
}

void saveFolderConfigurations(GlobalKey<FormState> formKey,
    FolderConfiguration folderConfiguration, BuildContext context) async {
  hideKeyboard(context);
  Provider.of<FolderConfigState>(context, listen: false).resetFolderCount();
  if (formKey.currentState!.validate()) {
    formKey.currentState!.save();
    final AppService appService =
        Provider.of<AppService>(context, listen: false);
    final bool connected = appService.connectionState;
    if (connected) {
      await appService.commandExecuter
          .foldersExist(folderConfiguration)
          .then((value) {
        if (value.isNotEmpty) {
          if (value["status"]) {
            appService.storage.saveObject(
                StorageKeys.folderConfigurations.key, folderConfiguration);
            appService.updateFolderConfigurations = folderConfiguration;
            showMessage(
                context: context, text: AppMessages.folderConfigurationSaved);
          } else {
            showMessage(
                duration: 10,
                context: context,
                multiline: true,
                text: generateFolderConfigurationNotSavedMessage(
                    value["notExist"]));
          }
        }
      });
    }
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

void setKindleDetails(bool value) {
  final BuildContext context =
      ContextKeys.serverFunctionsPagekey.currentContext!;
  final AppService appService = Provider.of<AppService>(context, listen: false);
  ServerFunctionsData serverFunctionsData =
      appService.storage.getServerFunctions;
  serverFunctionsData.sendTokindle = value;
  dailogBox(
      context: context,
      title: "Select Default Mailer",
      content: SizedBox(
        height: (AppMeasurements.deleteFileDailogBoxHeight *
                SupportedMailers.values.length)
            .h,
        child: ListView.separated(
          separatorBuilder: (context, index) => commonDivider,
          itemCount: SupportedMailers.values.length,
          itemBuilder: (BuildContext context, int index) {
            return TextButton(
              onPressed: () {
                appService.kindleData.mailer = SupportedMailers.values[index];
                Navigator.pop(context);
                kindleDataForm(serverFunctionsData);
              },
              child: Text(
                SupportedMailers.values[index].getName,
                style: AppTextStyles.regular(CommonColors.commonBlackColor,
                    AppFontSizes.dailogBoxTextFontSize.sp),
              ),
            );
          },
        ),
      ),
      actions: [
        if (serverFunctionsData.sendTokindle)
          TextButton(
            onPressed: () {
              serverFunctionsData.sendTokindle = false;
              appService.turnOffSendToKindle;
              saveServerFunctions(serverFunctionsData, context);
              Navigator.pop(context);
            },
            child: Text(
              "Turn Off",
              style: AppTextStyles.regular(CommonColors.commonBlackColor,
                  AppFontSizes.dialogBoxactionFontSixe.sp),
            ),
          ),
        dialogCancelButton(context),
      ]);
}

void kindleDataForm(ServerFunctionsData serverFunctionsData) {
  final BuildContext context =
      ContextKeys.serverFunctionsPagekey.currentContext!;
  final AppService appService = Provider.of<AppService>(context, listen: false);
  final kindleformKey = GlobalKey<FormState>();
  dailogBox(
      context: context,
      title: "Enter Kindle Details",
      content: SizedBox(
        height: AppMeasurements.kindleFormHeight.h,
        child: Form(
          key: kindleformKey,
          child: Column(children: [
            fromEmail(appService.kindleData),
            kindleEmail(appService.kindleData),
            apikey(appService.kindleData)
          ]),
        ),
      ),
      actions: [
        dialogCancelButton(context),
        TextButton(
          onPressed: () {
            if (kindleformKey.currentState!.validate()) {
              kindleformKey.currentState!.save();
              appService.storage.saveObject(
                  StorageKeys.serverFunctions.key, serverFunctionsData);
              appService.storage.saveObject(
                  StorageKeys.kindleData.key, appService.kindleData);
              appService.turnOffSendToKindle;
              Navigator.pop(context);
            }
          },
          child: Text(
            "Save",
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.dialogBoxactionFontSixe.sp),
          ),
        )
      ]);
}

Widget fromEmail(KindleData kindleData) => AppTextField.commonTextFeild(
      disableLeftRightPadding: true,
      onsaved: (data) {
        kindleData.fromEmail = data;
      },
      initialValue: kindleData.fromEmail,
      validator: validateEmail,
      keyboardType: TextInputType.emailAddress,
      labelText: "From Email",
      hintText: "Email Adress You Want To Send From",
    );

Widget kindleEmail(KindleData kindleData) => AppTextField.commonTextFeild(
      disableLeftRightPadding: true,
      onsaved: (data) {
        kindleData.kindleMailAddress = data;
      },
      initialValue: kindleData.kindleMailAddress,
      validator: validateEmail,
      keyboardType: TextInputType.emailAddress,
      labelText: "Kindle Email",
      hintText: "Email Adress Of Your Kindle",
    );

Widget apikey(KindleData kindleData) => AppTextField.commonTextFeild(
      disableLeftRightPadding: true,
      onsaved: (data) {
        kindleData.apiKey = data;
      },
      initialValue: kindleData.apiKey,
      validator: valueNeeded,
      keyboardType: const TextInputType.numberWithOptions(),
      labelText: "${kindleData.mailer.getName} API KEY",
      hintText: "API Key of ${kindleData.mailer.getName}",
    );

Widget editSendToKindle(bool value) {
  return Padding(
    padding: EdgeInsets.only(left: 18.w, right: 18.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText.singleLineText('Send To Kindle',
            style: AppTextStyles.medium(CommonColors.commonBlackColor,
                AppFontSizes.systemToolsTittleFontSize.sp)),
        TextButton(
          onPressed: () {
            setKindleDetails(value);
          },
          child: Text(
            "Edit",
            style: AppTextStyles.regular(CommonColors.commonLinkColor,
                AppFontSizes.dialogBoxactionFontSixe.sp),
          ),
        )
      ],
    ),
  );
}
