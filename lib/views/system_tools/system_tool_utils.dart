// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/common_widgets.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/models/commands/basic_details.dart';
import 'package:msm/models/commands/command_executer.dart';
import 'package:msm/models/server.dart';
import 'package:msm/models/storage.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/ui_components/text/text.dart';
import 'package:msm/ui_components/text/textstyles.dart';

Future<dynamic> speedTestOutput(BuildContext context) {
  return dailogBox(
      onlycancel: true,
      context: context,
      title: "Speed Test",
      content: SizedBox(height: 130.h, child: speedTester(context)));
}

Widget speedTester(BuildContext context) {
  final AppService appService = Provider.of<AppService>(context, listen: false);
  final bool connected = appService.connectionState;
  CommandExecuter commandExecuter = appService.commandExecuter;
  final Future<dynamic> speed = commandExecuter.speedTest();
  if (connected) {
    return FutureBuilder(
        future: speed,
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data != null) {
            if (snapshot.data.runtimeType == Speed) {
              return speedData(snapshot.data!);
            }
            return AppText.text(snapshot.data!,
                style: AppTextStyles.regular(
                    CommonColors.commonBlackColor, 15.sp));
          } else if (snapshot.hasError) {
            return Center(child: serverNotConnected(appService, text: false));
          } else {
            return commonCircularProgressIndicator;
          }
        });
  } else {
    return Center(child: serverNotConnected(appService, text: false));
  }
}

Widget speedData(Speed speedData) {
  return SingleChildScrollView(
    child: Column(
      children: [
        AppText.centerSingleLineText("Download",
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.noFilesFontSize.sp)),
        AppText.centerSingleLineText(speedData.downloadSpeed,
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.noFilesFontSize.sp)),
        AppText.centerSingleLineText("Upload",
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.noFilesFontSize.sp)),
        AppText.centerSingleLineText(speedData.uploadSpeed,
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.noFilesFontSize.sp)),
        AppText.centerSingleLineText("ISP",
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.noFilesFontSize.sp)),
        AppText.centerSingleLineText(speedData.isp,
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.noFilesFontSize.sp)),
        AppText.centerSingleLineText("Ping",
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.noFilesFontSize.sp)),
        AppText.centerSingleLineText(speedData.ping,
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.noFilesFontSize.sp)),
        AppText.centerSingleLineText("Country",
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.noFilesFontSize.sp)),
        AppText.centerSingleLineText(speedData.country,
            style: AppTextStyles.regular(
                CommonColors.commonBlackColor, AppFontSizes.noFilesFontSize.sp))
      ],
    ),
  );
}

Future<dynamic> systemUpdate(BuildContext context) {
  return dailogBox(
      onlycancel: true,
      context: context,
      title: "System Updation Process",
      content: updateProcess(context));
}

Widget updateProcess(BuildContext context) {
  final AppService appService = Provider.of<AppService>(context, listen: false);
  final bool connected = appService.connectionState;
  CommandExecuter commandExecuter = appService.commandExecuter;
  bool error = false;
  if (connected) {
    if (!appService.server.serverOS.dataAvailable) {
      commandExecuter.getDistribution(appService.storage).then((value) {
        if (value != null) {
          getUpdateCommandsFromGithub(value, appService.storage);
        } else {
          error = true;
        }
      });
    }
    final Future<dynamic> updateList = commandExecuter.updateList();
    return FutureBuilder(
        future: updateList,
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data != null) {
            if (error) {
              return AppText.text(
                  "Please Install lsb_release Command For This Feature To Work",
                  style: AppTextStyles.medium(
                      CommonColors.commonBlackColor, 15.sp));
            } else {
              if (snapshot.data!
                  .toString()
                  .contains("All packages are up to date.")) {
                return AppText.text(snapshot.data!,
                    style: AppTextStyles.regular(
                        CommonColors.commonBlackColor, 15.sp));
              }
              return SingleChildScrollView(
                child: Column(
                  children: [
                    AppText.text(snapshot.data!,
                        style: AppTextStyles.regular(
                            CommonColors.commonBlackColor, 15.sp)),
                    OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        showMessage(
                            context: context, text: "Sytem Upgrade Started");
                        await commandExecuter.systemUpgrade();
                      },
                      child: AppText.centerSingleLineText("Upgrade",
                          style: AppTextStyles.medium(
                              CommonColors.commonBlackColor, 15.sp)),
                    )
                  ],
                ),
              );
            }
          } else if (snapshot.hasError) {
            return Center(child: serverNotConnected(appService, text: false));
          } else {
            return commonCircularProgressIndicator;
          }
        });
  } else {
    return Center(child: serverNotConnected(appService, text: false));
  }
}

Future<void> getUpdateCommandsFromGithub(
    ServerOS serverOS, Storage storage) async {
  try {
    final Dio dio = Dio();
    final response = await dio.get(
      AppConstants.githubUpdateCommandsUrl,
    );
    if (response.statusCode == 200) {
      Map allCommandsData = jsonDecode(response.data);
      Map thisDistributionsCommands = allCommandsData[serverOS.serverOS];
      serverOS.updateCommand = thisDistributionsCommands["update"];
      serverOS.upgradeCommand = thisDistributionsCommands["upgrade"];
      serverOS.listCommand = thisDistributionsCommands["list"];
      serverOS.afterRunCommand = thisDistributionsCommands["after"];
      storage.saveObject(StorageKeys.serverOS.key, serverOS);
    }
  } catch (_) {}
}
