// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/common_widgets.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/models/background_tasks.dart';
import 'package:msm/models/file_manager.dart';
import 'package:msm/models/send_to_kindle.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/providers/file_listing_provider.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/ui_components/loading/loading_overlay.dart';
import 'package:msm/ui_components/text/textstyles.dart';
import 'package:msm/ui_components/textfield/textfield.dart';
import 'package:msm/ui_components/textfield/validators.dart';

PreferredSizeWidget searchBar(
    {required TextEditingController searchController,
    required FileListingState listingState}) {
  return AppBar(
    title: AppTextField.simpleTextField(
      controller: searchController,
      onChanged: (newValue) {
        listingState.setSearchText = newValue;
      },
    ),
    elevation: AppMeasurements.appBarElevation,
    backgroundColor: CommonColors.commonWhiteColor,
    leading: Padding(
      padding: EdgeInsets.only(left: 10.w, right: 10.w),
      child: IconButton(
        iconSize: AppFontSizes.appBarIconSize.sp,
        icon: const Icon(
          Icons.arrow_back,
          color: CommonColors.commonBlackColor,
        ),
        onPressed: () {
          listingState.setSearchMode = false;
          listingState.clearSearchText;
          searchController.text = '';
        },
      ),
    ),
  );
}

enum FileListPopMenu {
  all,
  moviesOnly,
  tvOnly,
  booksOnly,
  subtitlesOnly,
  customFolders,
  folders;

  String get menuText {
    switch (this) {
      case FileListPopMenu.all:
        return "All";
      case FileListPopMenu.moviesOnly:
        return "Movies";
      case FileListPopMenu.tvOnly:
        return "TV Shows";
      case FileListPopMenu.booksOnly:
        return "Books";
      case FileListPopMenu.subtitlesOnly:
        return "Subtitles";
      case FileListPopMenu.customFolders:
        return "Custom";
      case FileListPopMenu.folders:
        return "Folders";
    }
  }

  void applyFilter(FileListingState listingState) {
    switch (this) {
      case FileListPopMenu.all:
        return showAll(listingState);
      case FileListPopMenu.moviesOnly:
        return filterMoviesOnly(listingState);
      case FileListPopMenu.tvOnly:
        return filterTVOnly(listingState);
      case FileListPopMenu.booksOnly:
        return filterBooksOnly(listingState);
      case FileListPopMenu.subtitlesOnly:
        return filterSubtitleOnly(listingState);
      case FileListPopMenu.customFolders:
        return filterCustomFolders(listingState);
      case FileListPopMenu.folders:
        return foldersOnly(listingState);
    }
  }
}

enum FileActionMenu {
  rename,
  delete,
  move,
  download,
  sendKindle;

  String get menuText {
    switch (this) {
      case FileActionMenu.rename:
        return "Rename";
      case FileActionMenu.delete:
        return "Delete";
      case FileActionMenu.move:
        return "Move";
      case FileActionMenu.download:
        return "Download";
      case FileActionMenu.sendKindle:
        return "Send To Kindle";
    }
  }

  void executeAction(FileOrDirectory fileOrDirectory) {
    switch (this) {
      case FileActionMenu.rename:
        return renameFile(fileOrDirectory);
      case FileActionMenu.delete:
        return deleteSingleFile(fileOrDirectory);
      case FileActionMenu.move:
        return moveFile(fileOrDirectory);
      case FileActionMenu.download:
        return downloadFile(fileOrDirectory);
      case FileActionMenu.sendKindle:
        return sendToKindle(fileOrDirectory);
    }
  }
}

enum FileSorting {
  date,
  size,
  name;

  void sort() {
    switch (this) {
      case FileSorting.date:
        return sortOnDate;
      case FileSorting.size:
        return sortOnSize;
      case FileSorting.name:
        return sortOnName;
    }
  }
}

String generateSubtitle(FileOrDirectory fileOrDirectory) {
  String size = fileOrDirectory.size;
  String extention = fileOrDirectory.extention.toUpperCase();
  String date = fileOrDirectory.dateInFormat;
  String location = fileOrDirectory.location;
  return "$size, $extention, $date \n $location";
}

List<FileOrDirectory>? filterBasedOnSearchText(FileListingState listingState) {
  return listingState.currentList
      .where((fileOrDirectory) =>
          fileOrDirectory.name.contains(listingState.searchText))
      .toList();
}

void foldersOnly(FileListingState listingState) {
  listingState.currentList = listingState.originalList
      .where((fileOrDirectory) => !fileOrDirectory.isFile)
      .toList();
  listingState.applyFilter = true;
}

void showAll(FileListingState listingState) {
  listingState.currentList = listingState.originalList;
  listingState.applyFilter = true;
}

void filterMoviesOnly(FileListingState listingState) {
  listingState.currentList = listingState.originalList
      .where((fileOrDirectory) =>
          fileOrDirectory.location == listingState.folderConfiguration.movies)
      .toList();
  listingState.applyFilter = true;
}

void filterTVOnly(FileListingState listingState) {
  listingState.currentList = listingState.originalList
      .where((fileOrDirectory) =>
          fileOrDirectory.location == listingState.folderConfiguration.tv)
      .toList();
  listingState.applyFilter = true;
}

void filterBooksOnly(FileListingState listingState) {
  listingState.currentList = listingState.originalList
      .where((fileOrDirectory) =>
          fileOrDirectory.location == listingState.folderConfiguration.books)
      .toList();
  listingState.applyFilter = true;
}

void filterSubtitleOnly(FileListingState listingState) {
  listingState.currentList = listingState.originalList
      .where((fileOrDirectory) =>
          fileOrDirectory.extention ==
          FileManager.allowedSubtitlesExtentions.first)
      .toList();
  listingState.applyFilter = true;
}

void filterCustomFolders(FileListingState listingState) {
  listingState.currentList = listingState.originalList
      .where((fileOrDirectory) => listingState.folderConfiguration.customFolders
          .contains(fileOrDirectory.location))
      .toList();
  listingState.applyFilter = true;
}

void deleteSingleFile(FileOrDirectory fileOrDirectory) {
  BuildContext context = ContextKeys.fileListingPageKey.currentContext!;
  final AppService appService = Provider.of<AppService>(context, listen: false);
  dailogBox(
    context: context,
    content: Text(
      fileOrDirectory.name,
      style: AppTextStyles.regular(
          CommonColors.commonBlackColor, AppFontSizes.dailogBoxTextFontSize.sp),
    ),
    okOnPressed: () async {
      Navigator.pop(context, "OK");
      LoadingOverlay.of(context).show();
      await appService.commandExecuter
          .delete(fileOrDirectories: [fileOrDirectory]).then((value) {
        LoadingOverlay.of(context).hide();
        showMessage(
            context: context, text: AppMessages.filesDeletedSuccesfully);
        FileListingState fileListState =
            Provider.of<FileListingState>(context, listen: false);
        fileListState.clearSelection;
      });
    },
    title: AppConstants.deleteFilesTitle,
  );
}

void deletedSelected(FileListingState listingState) {
  BuildContext context = ContextKeys.fileListingPageKey.currentContext!;
  if (listingState.selectedList.isEmpty) {
    showMessage(context: context, text: AppMessages.filesNotSelected);
    return;
  }

  final AppService appService = Provider.of<AppService>(context, listen: false);
  dailogBox(
    context: context,
    content: SizedBox(
      height: (AppMeasurements.deleteFileDailogBoxHeight *
              listingState.selectedList.length)
          .h,
      child: ListView.separated(
        separatorBuilder: (context, index) => commonDivider,
        itemCount: listingState.selectedList.length,
        itemBuilder: (BuildContext context, int index) {
          return Text(
            listingState.selectedList[index].name,
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.dailogBoxTextFontSize.sp),
          );
        },
      ),
    ),
    okOnPressed: () async {
      Navigator.pop(context, "OK");
      LoadingOverlay.of(context).show();
      await appService.commandExecuter
          .delete(fileOrDirectories: listingState.selectedList)
          .then((value) {
        listingState.cancelModes;
        LoadingOverlay.of(context).hide();
        showMessage(
            context: context, text: AppMessages.filesDeletedSuccesfully);
        listingState.clearSelection;
      });
    },
    title: AppConstants.deleteFilesTitle,
  );
}

void renameFile(FileOrDirectory fileOrDirectory) {
  BuildContext context = ContextKeys.fileListingPageKey.currentContext!;
  final reNameFormKey = GlobalKey<FormState>();
  dailogBox(
    context: context,
    content: reNameField(reNameFormKey, context, fileOrDirectory),
    okOnPressed: () {
      hideKeyboard(context);
      if (reNameFormKey.currentState!.validate()) {
        reNameFormKey.currentState!.save();
      }
    },
    title: AppConstants.renameFile,
  );
}

Widget reNameField(
    Key key, BuildContext context, FileOrDirectory fileOrDirectory) {
  return Form(
    key: key,
    child: AppTextField.commonTextFeild(
      initialValue: fileOrDirectory.name,
      onsaved: (data) async {
        final AppService appService =
            Provider.of<AppService>(context, listen: false);
        Navigator.pop(context, "OK");
        LoadingOverlay.of(context).show();
        await appService.commandExecuter
            .rename(fileOrDirectory: fileOrDirectory, newName: data)
            .then((value) {
          LoadingOverlay.of(context).hide();
          showMessage(context: context, text: AppMessages.fileRename);
          FileListingState fileListState =
              Provider.of<FileListingState>(context, listen: false);
          fileListState.clearSelection;
        });
      },
      validator: valueNeeded,
      keyboardType: TextInputType.text,
      labelText: "New File Name",
      hintText: "File Rename",
    ),
  );
}

void moveFile(FileOrDirectory fileOrDirectory) {
  BuildContext context = ContextKeys.fileListingPageKey.currentContext!;
  dailogBox(
    onlycancel: true,
    context: context,
    content: moveLocations(context, fileOrDirectory),
    title: AppConstants.moveFile,
  );
}

Widget moveLocations(
    BuildContext mainContext, FileOrDirectory fileOrDirectory) {
  FileListingState fileListState =
      Provider.of<FileListingState>(mainContext, listen: false);
  List<String> locations = [
    fileListState.folderConfiguration.movies,
    fileListState.folderConfiguration.tv,
    fileListState.folderConfiguration.books,
    ...fileListState.folderConfiguration.customFolders
  ];
  return SizedBox(
    height: (AppMeasurements.deleteFileDailogBoxHeight * locations.length).h,
    child: ListView.separated(
      separatorBuilder: (context, index) => commonDivider,
      itemCount: locations.length,
      itemBuilder: (BuildContext context, int index) {
        return TextButton(
          onPressed: () async {
            final AppService appService =
                Provider.of<AppService>(context, listen: false);
            Navigator.pop(context, "OK");
            LoadingOverlay.of(mainContext).show();
            await appService.commandExecuter
                .move(
                    fileOrDirectory: fileOrDirectory,
                    newLocation: locations[index])
                .then((value) {
              LoadingOverlay.of(mainContext).hide();
              showMessage(context: context, text: AppMessages.moveFile);
              FileListingState fileListState =
                  Provider.of<FileListingState>(context, listen: false);
              fileListState.clearSelection;
            });
          },
          child: Text(
            locations[index].split("/").last.toUpperCase(),
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.dailogBoxTextFontSize.sp),
          ),
        );
      },
    ),
  );
}

void downloadFile(FileOrDirectory fileOrDirectory) async {
  BuildContext context = ContextKeys.fileListingPageKey.currentContext!;
  final AppService appService = Provider.of<AppService>(context, listen: false);
  BackgroundTasks.start();
  Timer(
      //timer implemented because background service will take some time to start
      const Duration(seconds: 3), () {
    BackgroundTasks().task(task: Task.download, appService: appService, data: {
      "fullPath": fileOrDirectory.fullPath,
      "name": fileOrDirectory.name
    });
  });
}

void sendToKindle(FileOrDirectory fileOrDirectory) async {
  BuildContext context = ContextKeys.fileListingPageKey.currentContext!;
  final AppService appService = Provider.of<AppService>(context, listen: false);
  if (appService.kindleData.dataAvailable) {
    await appService.commandExecuter
        .base64(fileOrDirectory: fileOrDirectory)
        .then((base64encodedString) async {
      if (base64encodedString.isNotEmpty) {
        SendTokindle sendTokindle = SendTokindle(
            base64EncodedData: base64encodedString,
            notifications: appService.notifications,
            enabled: true,
            fileName: fileOrDirectory.name,
            type: SupportedMailers.sendgrid,
            kindleData: appService.kindleData);
        await sendTokindle.sendMail(SupportedMailers.sendgrid).then((response) {
          if (response != null && response.statusCode == 202) {
            showMessage(context: context, text: AppMessages.sendToKindle);
          } else {
            showMessage(context: context, text: AppMessages.sendToKindleError);
          }
        });
      } else {
        showMessage(context: context, text: AppMessages.sendToKindleError);
      }
    });
  } else {
    context.goNamed(SettingsSubRoute.serverFunctions.toName);
    showMessage(context: context, text: AppMessages.setupKindleDetails);
  }
}

void get sortOnDate {
  BuildContext context = ContextKeys.fileListingPageKey.currentContext!;
  FileListingState listingState =
      Provider.of<FileListingState>(context, listen: false);
  listingState.originalList.sort((a, b) => b.date.compareTo(a.date));
  listingState.applyFilter = true;
}

void get sortOnSize {
  BuildContext context = ContextKeys.fileListingPageKey.currentContext!;
  FileListingState listingState =
      Provider.of<FileListingState>(context, listen: false);
  listingState.originalList.sort((a, b) => a.size.compareTo(b.size));
  listingState.applyFilter = true;
}

void get sortOnName {
  BuildContext context = ContextKeys.fileListingPageKey.currentContext!;
  FileListingState listingState =
      Provider.of<FileListingState>(context, listen: false);
  listingState.originalList.sort((a, b) => a.name.compareTo(b.name));
  listingState.applyFilter = true;
}
