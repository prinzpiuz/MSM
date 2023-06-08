// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/common_widgets.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/models/commands/command_executer.dart';
import 'package:msm/models/file_manager.dart';
import 'package:msm/models/folder_configuration.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/providers/upload_provider.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/ui_components/text/text.dart';
import 'package:msm/ui_components/text/textstyles.dart';
import 'package:msm/ui_components/textfield/textfield.dart';
import 'package:msm/ui_components/textfield/validators.dart';

enum UploadCatogories { movies, tvShows, books, custom }

extension UploadCategoriesExtention on UploadCatogories {
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
      default:
        return "";
    }
  }
}

void goToPage(UploadCatogories catogories, BuildContext context,
    {String path = ""}) {
  UploadState uploadState = Provider.of<UploadState>(context, listen: false);
  switch (catogories) {
    case UploadCatogories.movies:
      uploadState.setCategory = UploadCatogories.movies;
      uploadState.setCategoryExtentions = FileManager.allowedMovieExtentions;
      uploadState.setCurrentListing = UploadCatogories.movies.getTitle;
      break;
    case UploadCatogories.tvShows:
      uploadState.setCategory = UploadCatogories.tvShows;
      uploadState.setCategoryExtentions = FileManager.allowedMovieExtentions;
      uploadState.setCurrentListing = UploadCatogories.tvShows.getTitle;
      break;
    case UploadCatogories.books:
      uploadState.setCategory = UploadCatogories.books;
      uploadState.setCategoryExtentions = FileManager.allowedDocumentExtentions;
      uploadState.setCurrentListing = UploadCatogories.books.getTitle;
      break;
    case UploadCatogories.custom:
      uploadState.setCategory = UploadCatogories.custom;
      uploadState.setCategoryExtentions = FileManager.allAllowedExtentions;
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
    child: AppTextField.commonTextFeild(
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
  final AppService appService = Provider.of<AppService>(context, listen: false);
  final bool connected = appService.connectionState;
  if (connected) {
    String? directory = appService.server.folderConfiguration
        .pathToDirectory(uploadState.getCategory);
    if (uploadState.toCustomFolder) {
      directory = uploadState.customPath;
    }
    await appService.commandExecuter
        .upload(
            directory: directory!,
            filePaths: uploadState.fileUploadData.localFilesPaths,
            insidPath:
                FileManager.pathBuilder(uploadState.traversedDirectories),
            newFolders: uploadState.newFoldersToCreate)
        .then((value) {
      showMessage(
          context: context, text: AppMessages.uploadStarted, duration: 5);
      uploadState.fileUploadData.clear;
      uploadState.fileAddOrRemove;
      Navigator.pop(context);
    });
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

Widget menuBox(
    {IconData? icon,
    String? folderName,
    required Function onPressed,
    required double iconSize}) {
  return Container(
    color: CommonColors.commonGreenColor,
    child: OutlinedButton(
        onPressed: () => onPressed(),
        child: Center(
            child: icon != null
                ? Icon(icon,
                    color: CommonColors.commonWhiteColor, size: iconSize)
                : AppText.centerText(folderName!.toUpperCase(),
                    style: AppTextStyles.bold(
                        CommonColors.commonWhiteColor, iconSize)))),
  );
}

List<StaggeredGridTile> tiles(BuildContext context) {
  List<StaggeredGridTile> allTiles = [
    //default tiles
    StaggeredGridTile.count(
      crossAxisCellCount: 2,
      mainAxisCellCount: 2,
      child: menuBox(
          icon: Icons.movie_filter_outlined,
          onPressed: () => goToPage(UploadCatogories.movies, context),
          iconSize: AppFontSizes.homePageIconFontSize.h),
    ),
    StaggeredGridTile.count(
      crossAxisCellCount: 2,
      mainAxisCellCount: 4,
      child: menuBox(
          icon: Icons.tv,
          onPressed: () => goToPage(UploadCatogories.tvShows, context),
          iconSize: AppFontSizes.homePageIconFontSize.h),
    ),
    StaggeredGridTile.count(
      crossAxisCellCount: 2,
      mainAxisCellCount: 2,
      child: menuBox(
          icon: FontAwesomeIcons.bookOpen,
          onPressed: () => goToPage(UploadCatogories.books, context),
          iconSize: AppFontSizes.homePageIconFontSize.h),
    ),
  ];
  final AppService appService = Provider.of<AppService>(context);
  final FolderConfiguration folderConfiguration =
      appService.server.folderConfiguration;
  if (folderConfiguration.customFolders.isNotEmpty) {
    for (var customFolder in folderConfiguration.customFolders) {
      allTiles.add(StaggeredGridTile.count(
        crossAxisCellCount: 4,
        mainAxisCellCount: 1,
        child: menuBox(
            folderName: fileNameFromPath(customFolder),
            onPressed: () =>
                goToPage(UploadCatogories.custom, context, path: customFolder),
            iconSize: AppFontSizes.customFolderNameSize.h),
      ));
    }
  }
  return allTiles;
}
