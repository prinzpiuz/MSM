// Flutter imports:
import 'package:flutter/material.dart';

class AppFontSizes {
  static const serverStatFontSize = 13.0;
  static const homePageIconFontSize = 60.0;
  static const appBarIconSize = 28.0;
  static const smallTileIconSize = 30.0;
  static const titleBarFontSize = 15.0;
  static const noDataFontSize = 10.0;
  static const systemToolsIcon = 25.0;
  static const systemToolsTittleFontSize = 15.0;
  static const systemToolsSubtitleFontSize = 8.0;
  static const fileSortIconSize = 40;
  static const settingsSaveIconSize = 50;
  static const appShortNameFontSize = 20.0;
  static const appLongNameFontSize = 15.0;
  static const appInfoLinkFontSize = 12.0;
  static const connectingFontSize = 15.0;
  static const notConnectedIconSize = 90.0;
  static const notConnectedFontSize = 15.0;
  static const dialogBoxactionFontSixe = 13.0;
  static const dialogBoxTitleFontSize = 15.0;
  static const breadCrumbFontSize = 13.0;
  static const customFolderNameSize = 20.0;
  static const noFilesFontSize = 30.0;
  static const fileSearchFontSize = 13.0;
  static const fileListTitleFontSize = 12.0;
  static const fileListSubtitleFontSize = 8.0;
  static const fileMenuIconSize = 20.0;
  static const dailogBoxTextFontSize = 12.0;
}

class AppMeasurements {
  static const appBarElevation = 1.0;
  static const appInfoIconHeight = 100.0;
  static const appInfoIconWidth = 100.0;
  static const deleteFileDailogBoxHeight = 50.0;
  static const kindleFormHeight = 200.0;
  static const serverStatGap = 2.0;
  static const diskUsageIndicatorSize = 300.0;
  static const diskUsageIndicatorStrokeWidth = 15.0;
  static const realTimeDetailsTopPosition = 15.0;
  static const realTimeDetailsHorizontalMargin = 10.0;
}

class AppDurations {
  static const diskUsageAnimation = Duration(milliseconds: 2000);
}

class AppConstants {
  static const appIconImageLocation = "assets/svgs/msm.svg";
  static const appShortName = "MSM";
  static const appFullName = "Media Server Manager";
  static const appIssueFeatureReport = "Click Here To Submit Bugs";
  static const issueReportUrl = "https://github.com/prinzpiuz/MSM/issues";
  static const homePage = "Home Page";
  static const homePageUrl = "https://prinzpiuz.in/MSM/";
  static const license = "License";
  static const licenseUrl =
      "https://github.com/prinzpiuz/MSM/blob/refactored/LICENSE";
  static const alphaAndSpecialChars = r'/^[ A-Za-z_@./#&+-]*$/.';
  static const emailvalidationRegex =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
  static const upperLower = "[a-zA-Z]";
  static const lowerCase = "[a-z]";
  static const ipFormat = "[0-9.]";
  static const numberOnly = "[0-9]";
  static const macFormat = "[A-Z0-9:]";
  static const connecting = "Connecting....";
  static const notConnected = "Not Connected";
  static const notAvailable = "Not Available";
  static const connected = "Connected";
  static const disconnected = "Disconnected";
  static const uploadSize = 1073741824;
  static const deleteFilesTitle = "Delete These Files?";
  static const renameFile = "Enter New Name";
  static const moveFile = "Select The Folder To Move";
  static const githubUpdateCommandsUrl =
      "https://raw.githubusercontent.com/prinzpiuz/MSM/refactored/linux_update_commands.json";
}

class AppMessages {
  static const serverDetailSaved = "Saved Server Details";
  static const folderConfigurationSaved = "Saved Folder Configurations";
  static const serverFunctionSaved = "Saved Server Functions";
  static const addMacAddress = "Make Sure You Save \n MAC Address Also";
  static const selectFiles = "Select Files";
  static const connectionLost = "Connection Lost";
  static const uploadStarted = "Upload Will Start In Background";
  static const errorOccurred = "Error While Uploading";
  static const clearingTasks = "All Background Tasks Cleared";
  static const folderCreationError = "Error Occurred While Creating Folders";
  static const serverNotAvailable = "Server Not Available";
  static const filesNotSelected = "Files Not Selected";
  static const filesDeletedSuccessfully = "Files Deleted Successfully";
  static const fileRename = "File Renamed Successfully";
  static const moveFile = "File Moved Successfully";
  static const sendToKindle = "File Successfully Sent To Kindle";
  static const sendToKindleError = "File Sending To Kindle Failed \n Try Again";
  static const setupKindleDetails = "Please Add Required Kindle Details";
  static const sshKeyNotUploaded = "SSH Key Not Uploaded";
  static const sshKeyUploaded = "SSH Key Uploaded Successfully";
  static const fillDetails = "Fill Server Details First";
  static const errorSavingFolderConfig =
      "An error occurred while saving folder configuration:";
  static const folderVerifyError =
      "Unable to verify folder existence. Please try again.";
}

class BackgroundTaskUniqueNames {
  static const upload = "upload";
  static const update = "update";
  static const cleanServer = "cleanServer";
  static const download = "download";
}

class AppDictKeys {
  static const directory = "directory";
  static const filePath = "filePath";
  static const fileSize = "fileSize";
}

class Identifiers {
  static const username = "username";
  static const uptime = "uptime";
  static const temperature = "temperature";
  static const disk = "disk";
  static const ram = "ram";
  static const distribution = "distribution";

  Identifiers._();
}

class ContextKeys {
  static GlobalKey<NavigatorState> fileListingPageKey =
      GlobalKey<NavigatorState>();
  static GlobalKey<ScaffoldState> serverFunctionsPagekey =
      GlobalKey<ScaffoldState>();
}

class BackGroundTaskRelated {
  static const notificationChannelId = "background_notification";
  static const foregroundServiceNotificationId = 888;
  static const initialNotificationContent = "Background Service Initializing";
  static const initialNotificationTitle = "MSM";
  static const runningBody = "Background Service Running";
  static const icon = "ic_bg_service_small";
  static const stopActionId = "stop_service";
  static const stopActionTitle = "Stop Service";
  static const uploadChannelId = "upload";
  static const uploadChannelName = "upload channel";
  static const uploadNotificationId = 123;
}

class ShellScriptPaths {
  static const basicDetails = "shell_scripts/basic_details.sh";
}
