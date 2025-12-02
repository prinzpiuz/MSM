// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:msm/common_widgets.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/providers/upload_provider.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/ui_components/text/text.dart';
import 'package:msm/ui_components/text/textstyles.dart';
import 'package:msm/ui_components/textfield/textfield.dart';
import 'package:msm/ui_components/textfield/validators.dart';
// Project imports:
import 'package:msm/utils.dart';
import 'package:msm/utils/background_tasks.dart';
import 'package:msm/utils/commands/command_executer.dart';
import 'package:msm/utils/file_manager.dart';
import 'package:msm/utils/folder_configuration.dart';

enum UploadCatogories { movies, tvShows, books, custom }

extension UploadCategoriesExtension on UploadCatogories {
  String get getTitle {
    switch (this) {
      case UploadCatogories.movies:
        return "Movies";
      case UploadCatogories.tvShows:
        return "TV Shows";
      case UploadCatogories.books:
        return "Books";
      case UploadCatogories.custom:
        return "Custom";
      }
  }
}

void goToPage(UploadCatogories catogories, BuildContext context,
    {String path = ""}) {
  UploadState uploadState = Provider.of<UploadState>(context, listen: false);
  switch (catogories) {
    case UploadCatogories.movies:
      uploadState.setCategory = UploadCatogories.movies;
      uploadState.setCategoryExtensions = FileManager.allowedMovieExtensions;
      uploadState.setCurrentListing = UploadCatogories.movies.getTitle;
      break;
    case UploadCatogories.tvShows:
      uploadState.setCategory = UploadCatogories.tvShows;
      uploadState.setCategoryExtensions = FileManager.allowedMovieExtensions;
      uploadState.setCurrentListing = UploadCatogories.tvShows.getTitle;
      break;
    case UploadCatogories.books:
      uploadState.setCategory = UploadCatogories.books;
      uploadState.setCategoryExtensions = FileManager.allowedDocumentExtensions;
      uploadState.setCurrentListing = UploadCatogories.books.getTitle;
      break;
    case UploadCatogories.custom:
      uploadState.setCategory = UploadCatogories.custom;
      uploadState.setCategoryExtensions = FileManager.allAllowedExtensions;
      uploadState.toCustomFolder = true;
      if (path.isNotEmpty) {
        uploadState.customPath = path;
        uploadState.setCurrentListing = fileNameFromPath(path);
      }
      break;
  }
  return GoRouter.of(context).go(Pages.commonUpload.toPath);
}

void goInside(FileOrDirectory fileOrDirectory, UploadState uploadState,
    BuildContext context) {
  if (!fileOrDirectory.isFile) {
    uploadState.setRecursive = true;
    uploadState.setNextFilesDirectory = Directory(fileOrDirectory.location);
    goToPage(uploadState.getCategory, context);
  }
}

String getBackPage(UploadState uploadState) {
  if (uploadState.getNextFilesDirectory.isEmpty) {
    return Pages.upload.toPath;
  } else {
    return Pages.commonUpload.toPath;
  }
}

Future<void> bottomSheet(BuildContext context, UploadState uploadState,
    {bool saveHere = false, String? insidePath}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return sendMenu(context, uploadState,
          saveHere: saveHere, insidePath: insidePath);
    },
  );
}

void getInsideFolder(
    BuildContext context, UploadState uploadState, String name) {
  Navigator.of(context).pop();
  uploadState.addRemoteDirectoru(name);
  bottomSheet(context, uploadState,
      saveHere: true,
      insidePath: FileManager.pathBuilder(uploadState.traversedDirectories));
}

void createNewFolder(BuildContext context, UploadState uploadState) {
  uploadState.empty = true;
  final newFolderNameFormKey = GlobalKey<FormState>();
  dailogBox(
    context: context,
    title: "Enter New Folder Name",
    content: newFolderNameField(newFolderNameFormKey, uploadState),
    okOnPressed: () {
      hideKeyboard(context);
      validateFolderName(newFolderNameFormKey);
      if (uploadState.newFolderName.isNotEmpty) {
        Navigator.pop(context, "OK");
      }
    },
  );
}

Widget newFolderNameField(Key key, UploadState uploadState) {
  return Form(
    key: key,
    child: AppTextField.commonTextField(
      onsaved: (data) {
        uploadState.newFolderName = data;
        uploadState.addNewFolderName(data);
      },
      validator: valueNeeded,
      keyboardType: TextInputType.text,
      labelText: "New Folder Name",
      hintText: "Name Of New Folder You Want To Create",
    ),
  );
}

void validateFolderName(GlobalKey<FormState> formKey) {
  if (formKey.currentState!.validate()) {
    formKey.currentState!.save();
  }
}

void uploadFiles(BuildContext context, UploadState uploadState) async {
  BackgroundTasks.start();
  final AppService appService = Provider.of<AppService>(context, listen: false);
  final bool connected = appService.connectionState;
  if (connected) {
    String? directory = appService.server.folderConfiguration
        .pathToDirectory(uploadState.getCategory);
    if (uploadState.toCustomFolder) {
      directory = uploadState.customPath;
    }
    showMessage(context: context, text: AppMessages.uploadStarted, duration: 5);
    Navigator.pop(context);
    Timer(
        //timer implemented because background service will take some time to start
        const Duration(seconds: 3), () {
      BackgroundTasks().task(
          task: Task.upload,
          data: {
            "directory": directory!,
            "filePaths": uploadState.fileUploadData.localFilesPaths,
            "insidePath":
                FileManager.pathBuilder(uploadState.traversedDirectories),
            "newFolders": uploadState.newFoldersToCreate
          },
          appService: appService);
      uploadState.fileAddOrRemove;
      uploadState.fileUploadData.clear;
    });
    //////////////////////
    // final SftpClient sftpClient =
    //     await appService.commandExecuter.client!.sftp();
    // await upload(
    //     directory: directory!,
    //     filePaths: uploadState.fileUploadData.localFilesPaths,
    //     sftp: sftpClient,
    //     notifications: appService.commandExecuter.notifications);
    ///////////////////
    // });
  } else {
    showMessage(context: context, text: AppMessages.connectionLost);
  }
}

Widget folderButton(BuildContext context, UploadState uploadState,
    {String name = '', bool newFolder = true, bool saveHere = false}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      saveHere
          ? IconButton(
              icon: const Icon(
                Icons.save_alt,
                color: CommonColors.commonGreenColor,
              ),
              onPressed: () => uploadFiles(context, uploadState))
          : IconButton(
              icon: Icon(newFolder ? Icons.create_new_folder : Icons.folder),
              onPressed: () {
                if (name.isNotEmpty) {
                  getInsideFolder(context, uploadState, name);
                }
                if (newFolder) {
                  createNewFolder(context, uploadState);
                }
              }),
      saveHere
          ? AppText.centerText("Save Here",
              style:
                  AppTextStyles.extraBold(CommonColors.commonGreenColor, 8.sp))
          : AppText.singleLineText(newFolder ? "New" : name,
              style: AppTextStyles.bold(CommonColors.commonBlackColor, 8.sp)),
    ],
  );
}

void addOrRemove(FileOrDirectory data, UploadState uploadState) {
  uploadState.fileUploadData.addOrRemove(data);
  uploadState.fileAddOrRemove;
}

List<Widget> getServerFolders(BuildContext context, UploadState uploadState,
    List<FileOrDirectory>? folders) {
  List<Widget> outFolders = [];
  if (folders != null && folders.isNotEmpty) {
    for (FileOrDirectory folder in folders) {
      outFolders.add(folderButton(context, uploadState,
          name: folder.name, newFolder: false));
    }
  }

  return outFolders;
}

List<Widget> generateFolders(BuildContext context, UploadState uploadState,
    List<FileOrDirectory>? data, bool saveHere) {
  List<Widget> children;
  children = <Widget>[
    if (saveHere) folderButton(context, uploadState, saveHere: saveHere),
    folderButton(context, uploadState),
    ...getServerFolders(context, uploadState, data)
  ];
  return children;
}

Widget foldersGrid(BuildContext context, UploadState uploadState,
    List<FileOrDirectory>? data, bool saveHere) {
  return Container(
      height: 300.h,
      color: CommonColors.commonWhiteColor,
      child: GridView.count(
          padding: EdgeInsets.all(15.h),
          crossAxisCount: 4,
          children: generateFolders(context, uploadState, data, saveHere)));
}

Widget bottomSheetContent(BuildContext context, UploadState uploadState,
    AppService appService, List<FileOrDirectory>? data, bool saveHere) {
  return Column(
    children: [
      breadCrumbs(uploadState, appService),
      foldersGrid(context, uploadState, data, saveHere),
    ],
  );
}

Widget breadCrumbs(UploadState uploadState, AppService appService) {
  String? directory = appService.server.folderConfiguration
      .pathToDirectory(uploadState.getCategory);
  if (uploadState.toCustomFolder) {
    directory = uploadState.customPath;
  }
  String breadCrumbString = directory ?? uploadState.getCategory.getTitle;
  if (uploadState.traversedDirectories.isNotEmpty) {
    for (String folderName in uploadState.traversedDirectories) {
      breadCrumbString += " > $folderName";
    }
  }
  if (uploadState.newFoldersToCreate.isNotEmpty) {
    for (String folderName in uploadState.newFoldersToCreate) {
      breadCrumbString += " > $folderName";
    }
  }
  return Padding(
    padding: EdgeInsets.only(top: 18.h),
    child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: AppText.singleLineText(breadCrumbString,
            style: AppTextStyles.bold(CommonColors.commonBlackColor,
                AppFontSizes.breadCrumbFontSize.sp))),
  );
}

Widget sendMenu(BuildContext context, UploadState uploadState,
    {bool saveHere = false, String? insidePath}) {
  final AppService appService = Provider.of<AppService>(context);
  final bool connected = appService.connectionState;
  if (connected) {
    CommandExecuter commandExecuter = appService.commandExecuter;
    final Future<List<FileOrDirectory>?>? directoryData =
        commandExecuter.listRemoteDirectory(uploadState.getCategory, insidePath,
            empty: uploadState.empty, customPath: uploadState.customPath);
    //TODO handle the case if not folder config data available
    return FutureBuilder<List<FileOrDirectory>?>(
      future: directoryData,
      builder: (BuildContext context,
          AsyncSnapshot<List<FileOrDirectory>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return bottomSheetContent(
              context, uploadState, appService, snapshot.data, saveHere);
        } else {
          return commonCircularProgressIndicator;
        }
      },
    );
  } else {
    return serverNotConnected(appService);
  }
}

List<Widget> locations(BuildContext context) {
  final AppService appService = Provider.of<AppService>(context);
  final FolderConfiguration folderConfiguration =
      appService.server.folderConfiguration;
  List<Widget> allTiles = [
    //default tiles
    commonTile(
      icon: Icons.movie_filter_outlined,
      title: UploadCatogories.movies.getTitle,
      subtitle: folderConfiguration.pathToDirectory(UploadCatogories.movies),
      onTap: () => goToPage(UploadCatogories.movies, context),
    ),
    commonTile(
      icon: Icons.tv_sharp,
      title: UploadCatogories.tvShows.getTitle,
      subtitle: folderConfiguration.pathToDirectory(UploadCatogories.tvShows),
      onTap: () => goToPage(UploadCatogories.tvShows, context),
    ),
    commonTile(
      icon: Icons.menu_book_sharp,
      title: UploadCatogories.books.getTitle,
      subtitle: folderConfiguration.pathToDirectory(UploadCatogories.books),
      onTap: () => goToPage(UploadCatogories.books, context),
    )
  ];
  if (folderConfiguration.customFolders.isNotEmpty) {
    for (var customFolder in folderConfiguration.customFolders) {
      allTiles.add(commonTile(
        icon: Icons.folder,
        title: fileNameFromPath(customFolder),
        subtitle: customFolder,
        onTap: () =>
            goToPage(UploadCatogories.custom, context, path: customFolder),
      ));
    }
  }
  return allTiles;
}
