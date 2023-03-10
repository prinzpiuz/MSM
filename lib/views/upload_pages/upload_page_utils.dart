// Dart imports:
import 'dart:io';

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
import 'package:msm/models/commands/command_executer.dart';
import 'package:msm/models/file_manager.dart';
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

void goToPage(UploadCatogories catogories, BuildContext context) {
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
      uploadState.setCategoryExtentions = FileManager.allowedPictureExtentions;
      uploadState.setCurrentListing = UploadCatogories.custom.getTitle;
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
    CommandExecuter commandExecuter = appService.commandExecuter;
    commandExecuter
        .upload(
            category: uploadState.getCategory,
            fileUploadData: uploadState.fileUploadData,
            newFolders: uploadState.newFoldersToCreate,
            insidPath:
                FileManager.pathBuilder(uploadState.traversedDirectories))
        .then((uploaded) {
      if (uploaded) {
        uploadState.fileUploadData.clear;
        uploadState.fileAddOrRemove;
      } else {
        showMessage(
            context: context, text: AppMessages.errorOccured, duration: 5);
      }
    });
    showMessage(context: context, text: AppMessages.uploadStarted, duration: 5);
    Navigator.pop(context);
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
  String breadCrumbString = appService.server.folderConfiguration
          .pathToDirectory(uploadState.getCategory) ??
      uploadState.getCategory.getTitle;
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
            empty: uploadState.empty);
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
