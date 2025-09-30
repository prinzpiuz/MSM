// Dart imports:
// ignore_for_file: use_build_context_synchronously

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
import 'package:msm/providers/file_listing_provider.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/ui_components/loading/loading_overlay.dart';
import 'package:msm/ui_components/text/textstyles.dart';
import 'package:msm/ui_components/textfield/textfield.dart';
import 'package:msm/ui_components/textfield/validators.dart';
// Project imports:
import 'package:msm/utils.dart';
import 'package:msm/utils/background_tasks.dart';
import 'package:msm/utils/file_manager.dart';
import 'package:msm/utils/send_to_kindle.dart';

/// Constants for file listing utilities.
class FileListingConstants {
  static const Duration backgroundTaskStartDelay = Duration(seconds: 3);
}

/// Builds the search bar widget for file listing.
///
/// [searchController] - Controller for the search text field.
/// [listingState] - State provider for file listing.
PreferredSizeWidget searchBar({
  required TextEditingController searchController,
  required FileListingState listingState,
}) {
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
          searchController.clear();
        },
      ),
    ),
  );
}

/// Enum for file list popup menu options.
enum FileListPopMenu {
  all,
  moviesOnly,
  tvOnly,
  booksOnly,
  subtitlesOnly,
  customFolders,
  folders;

  /// Returns the display text for the menu option.
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

  /// Applies the filter to the listing state.
  void applyFilter(FileListingState listingState) {
    switch (this) {
      case FileListPopMenu.all:
        return _showAll(listingState);
      case FileListPopMenu.moviesOnly:
        return _filterMoviesOnly(listingState);
      case FileListPopMenu.tvOnly:
        return _filterTVOnly(listingState);
      case FileListPopMenu.booksOnly:
        return _filterBooksOnly(listingState);
      case FileListPopMenu.subtitlesOnly:
        return _filterSubtitleOnly(listingState);
      case FileListPopMenu.customFolders:
        return _filterCustomFolders(listingState);
      case FileListPopMenu.folders:
        return _foldersOnly(listingState);
    }
  }
}

/// Enum for file action menu options.
enum FileActionMenu {
  rename,
  delete,
  move,
  download,
  sendKindle;

  /// Returns the display text for the menu option.
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

  /// Executes the action on the file or directory.
  void executeAction(FileOrDirectory fileOrDirectory) {
    switch (this) {
      case FileActionMenu.rename:
        // Rename action is handled separately via dialog
        break;
      case FileActionMenu.delete:
        // Delete action is handled separately
        break;
      case FileActionMenu.move:
        return _moveFile(fileOrDirectory);
      case FileActionMenu.download:
        return _downloadFile(fileOrDirectory);
      case FileActionMenu.sendKindle:
        return _sendToKindle(fileOrDirectory);
    }
  }
}

/// Enum for file sorting options.
enum FileSorting {
  date,
  size,
  name;

  /// Sorts the file list based on the selected option.
  void sort() {
    switch (this) {
      case FileSorting.date:
        _sortOnDate();
        break;
      case FileSorting.size:
        _sortOnSize();
        break;
      case FileSorting.name:
        _sortOnName();
        break;
    }
  }
}

/// Performs sorting on the original list using the provided comparator.
///
/// [comparator] - Function to compare two FileOrDirectory objects.
void _performSort(
    int Function(FileOrDirectory a, FileOrDirectory b) comparator) {
  final BuildContext? context = ContextKeys.fileListingPageKey.currentContext;
  if (context == null) {
    debugPrint('Context is null, cannot perform sort.');
    return;
  }
  final FileListingState listingState =
      Provider.of<FileListingState>(context, listen: false);
  if (listingState.originalList.isEmpty) return;
  listingState.originalList.sort(comparator);
  listingState.applyFilter = true;
}

/// Generates a subtitle string for a file or directory.
///
/// [fileOrDirectory] - The file or directory to generate subtitle for.
String generateSubtitle(FileOrDirectory fileOrDirectory) {
  final String size = fileOrDirectory.size;
  final String extension = fileOrDirectory.extension.toUpperCase();
  final String date = fileOrDirectory.dateInFormat;
  final String location = fileOrDirectory.location;
  return "$size, $extension, $date \n $location";
}

/// Filters the current list based on search text.
///
/// [listingState] - State provider for file listing.
/// Returns the filtered list or null if no search text.
List<FileOrDirectory>? filterBasedOnSearchText(FileListingState listingState) {
  if (listingState.searchText.isEmpty) return null;
  return listingState.currentList
      .where((fileOrDirectory) => fileOrDirectory.name
          .toLowerCase()
          .contains(listingState.searchText.toLowerCase()))
      .toList();
}

/// Filters to show only folders.
///
/// [listingState] - State provider for file listing.
void _foldersOnly(FileListingState listingState) {
  listingState.currentList = listingState.originalList
      .where((fileOrDirectory) => !fileOrDirectory.isFile)
      .toList();
  listingState.applyFilter = true;
}

/// Shows all files and directories.
///
/// [listingState] - State provider for file listing.
void _showAll(FileListingState listingState) {
  listingState.currentList = List.from(listingState.originalList);
  listingState.applyFilter = true;
}

/// Filters to show only movies.
///
/// [listingState] - State provider for file listing.
void _filterMoviesOnly(FileListingState listingState) {
  listingState.currentList = listingState.originalList
      .where((fileOrDirectory) =>
          fileOrDirectory.location == listingState.folderConfiguration.movies)
      .toList();
  listingState.applyFilter = true;
}

/// Filters to show only TV shows.
///
/// [listingState] - State provider for file listing.
void _filterTVOnly(FileListingState listingState) {
  listingState.currentList = listingState.originalList
      .where((fileOrDirectory) =>
          fileOrDirectory.location == listingState.folderConfiguration.tv)
      .toList();
  listingState.applyFilter = true;
}

/// Filters to show only books.
///
/// [listingState] - State provider for file listing.
void _filterBooksOnly(FileListingState listingState) {
  listingState.currentList = listingState.originalList
      .where((fileOrDirectory) =>
          fileOrDirectory.location == listingState.folderConfiguration.books)
      .toList();
  listingState.applyFilter = true;
}

/// Filters to show only subtitles.
///
/// [listingState] - State provider for file listing.
void _filterSubtitleOnly(FileListingState listingState) {
  listingState.currentList = listingState.originalList
      .where((fileOrDirectory) =>
          fileOrDirectory.extension ==
          FileManager.allowedSubtitlesExtensions.first)
      .toList();
  listingState.applyFilter = true;
}

/// Filters to show only custom folders.
///
/// [listingState] - State provider for file listing.
void _filterCustomFolders(FileListingState listingState) {
  listingState.currentList = listingState.originalList
      .where((fileOrDirectory) => listingState.folderConfiguration.customFolders
          .contains(fileOrDirectory.location))
      .toList();
  listingState.applyFilter = true;
}

/// Deletes selected files.
///
/// [listingState] - State provider for file listing.
void deleteSelected(FileListingState listingState) {
  final BuildContext? context = ContextKeys.fileListingPageKey.currentContext;
  if (context == null) {
    debugPrint('Context is null, cannot delete selected files.');
    return;
  }
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
      try {
        await appService.commandExecuter
            .delete(fileOrDirectories: listingState.selectedList);
        listingState.cancelModes;
        LoadingOverlay.of(context).hide();
        showMessage(
            context: context, text: AppMessages.filesDeletedSuccessfully);
        listingState.clearSelection;
      } catch (e) {
        LoadingOverlay.of(context).hide();
        showMessage(context: context, text: AppMessages.errorOccurred);
        debugPrint('Error deleting files: $e');
      }
    },
    title: AppConstants.deleteFilesTitle,
  );
}

/// Moves a file to a new location.
///
/// [fileOrDirectory] - The file or directory to move.
void _moveFile(FileOrDirectory fileOrDirectory) {
  final BuildContext? context = ContextKeys.fileListingPageKey.currentContext;
  if (context == null) {
    debugPrint('Context is null, cannot move file.');
    return;
  }
  dailogBox(
    onlycancel: true,
    context: context,
    content: _buildMoveLocations(context, fileOrDirectory),
    title: AppConstants.moveFile,
  );
}

/// Builds the widget for selecting move locations.
///
/// [mainContext] - The main build context.
/// [fileOrDirectory] - The file or directory to move.
Widget _buildMoveLocations(
    BuildContext mainContext, FileOrDirectory fileOrDirectory) {
  final FileListingState fileListState =
      Provider.of<FileListingState>(mainContext, listen: false);
  final List<String> locations = [
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
            try {
              await appService.commandExecuter.move(
                  fileOrDirectory: fileOrDirectory,
                  newLocation: locations[index]);
              LoadingOverlay.of(mainContext).hide();
              showMessage(context: context, text: AppMessages.moveFile);
              final FileListingState fileListState =
                  Provider.of<FileListingState>(context, listen: false);
              fileListState.clearSelection;
            } catch (e) {
              LoadingOverlay.of(mainContext).hide();
              showMessage(context: context, text: AppMessages.errorOccurred);
              debugPrint('Error moving file: $e');
            }
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

/// Downloads a file.
///
/// [fileOrDirectory] - The file to download.
void _downloadFile(FileOrDirectory fileOrDirectory) async {
  final BuildContext? context = ContextKeys.fileListingPageKey.currentContext;
  if (context == null) {
    debugPrint('Context is null, cannot download file.');
    return;
  }
  final AppService appService = Provider.of<AppService>(context, listen: false);
  BackgroundTasks.start();
  Timer(FileListingConstants.backgroundTaskStartDelay, () {
    BackgroundTasks().task(task: Task.download, appService: appService, data: {
      "fullPath": fileOrDirectory.fullPath,
      "name": fileOrDirectory.name
    });
  });
}

/// Sends a file to Kindle.
///
/// [fileOrDirectory] - The file to send.
void _sendToKindle(FileOrDirectory fileOrDirectory) async {
  final BuildContext? context = ContextKeys.fileListingPageKey.currentContext;
  if (context == null) {
    debugPrint('Context is null, cannot send to Kindle.');
    return;
  }
  final AppService appService = Provider.of<AppService>(context, listen: false);
  final FileListingState fileListState =
      Provider.of<FileListingState>(context, listen: false);
  if (appService.kindleData.dataAvailable) {
    fileListState.setIsLoading = true;
    try {
      final String base64encodedString = await appService.commandExecuter
          .base64(fileOrDirectory: fileOrDirectory);
      if (base64encodedString.isNotEmpty) {
        final SendTokindle sendTokindle = SendTokindle(
            base64EncodedData: base64encodedString,
            notifications: appService.notifications,
            enabled: true,
            fileName: fileOrDirectory.name,
            kindleData: appService.kindleData);
        final bool send = await sendTokindle.sendMail();
        fileListState.setIsLoading = false;
        if (send) {
          showMessage(context: context, text: AppMessages.sendToKindle);
        } else {
          showMessage(context: context, text: AppMessages.sendToKindleError);
        }
      } else {
        fileListState.setIsLoading = false;
        showMessage(context: context, text: AppMessages.sendToKindleError);
      }
    } catch (e) {
      fileListState.setIsLoading = false;
      showMessage(context: context, text: AppMessages.sendToKindleError);
      debugPrint('Error sending to Kindle: $e');
    }
  } else {
    context.goNamed(SettingsSubRoute.serverFunctions.toName);
    showMessage(context: context, text: AppMessages.setupKindleDetails);
  }
}

/// Sorts files by date (descending).
void _sortOnDate() => _performSort((a, b) => b.date.compareTo(a.date));

/// Sorts files by size (ascending).
void _sortOnSize() =>
    _performSort((a, b) => a.sizeInInt.compareTo(b.sizeInInt));

/// Sorts files by name (ascending).
void _sortOnName() => _performSort((a, b) => a.name.compareTo(b.name));

/// Deletes a single file.
///
/// [context] - The build context.
/// [fileOrDirectory] - The file or directory to delete.
/// [extraFunctionCallback] - Optional callback after deletion.
void deleteSingleFile(BuildContext context, FileOrDirectory fileOrDirectory,
    {Function? extraFunctionCallback}) async {
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
      try {
        await appService.commandExecuter
            .delete(fileOrDirectories: [fileOrDirectory]);
        LoadingOverlay.of(context).hide();
        showMessage(
            context: context, text: AppMessages.filesDeletedSuccessfully);
        final FileListingState fileListState =
            Provider.of<FileListingState>(context, listen: false);
        fileListState.currentList.remove(fileOrDirectory);
        extraFunctionCallback?.call();
      } catch (e) {
        LoadingOverlay.of(context).hide();
        showMessage(context: context, text: AppMessages.errorOccurred);
        debugPrint('Error deleting single file: $e');
      }
    },
    title: AppConstants.deleteFilesTitle,
  );
}

/// Shows the rename file dialog.
///
/// [context] - The build context.
/// [fileOrDirectory] - The file or directory to rename.
/// [reNameFormKey] - Form key for validation.
/// [renameField] - The widget for rename input.
void renameFile(BuildContext context, FileOrDirectory fileOrDirectory,
    GlobalKey<FormState> reNameFormKey,
    {Widget? renameField}) {
  dailogBox(
    context: context,
    content: renameField,
    okOnPressed: () {
      hideKeyboard(context);
      if (reNameFormKey.currentState!.validate()) {
        reNameFormKey.currentState!.save();
      }
    },
    title: AppConstants.renameFile,
  );
}

/// Builds the rename field widget.
///
/// [key] - Form key.
/// [context] - Build context.
/// [fileOrDirectory] - The file or directory to rename.
/// [controller] - Text controller.
/// [extraFunctionCallback] - Optional callback.
Widget reNameField({
  required Key key,
  required BuildContext context,
  required FileOrDirectory fileOrDirectory,
  required TextEditingController controller,
  Function? extraFunctionCallback,
}) {
  return Form(
    key: key,
    child: AppTextField.commonTextField(
      initialValue: fileOrDirectory.name,
      onsaved: (data) async {
        controller.text = data;
        final FileListingState fileListState =
            Provider.of<FileListingState>(context, listen: false);
        try {
          final FileOrDirectory updatedFile = fileOrDirectory.isFile
              ? FileObject(
                  File(fileOrDirectory.fullPath),
                  data,
                  fileOrDirectory.sizeInInt,
                  fileOrDirectory.extension,
                  fileOrDirectory.location,
                  fileOrDirectory.type,
                  fileOrDirectory.fullPath,
                  fileOrDirectory.remote,
                  fileOrDirectory.category,
                  fileOrDirectory.date)
              : DirectoryObject(
                  Directory(fileOrDirectory.fullPath),
                  data,
                  fileOrDirectory.sizeInInt,
                  fileOrDirectory.type,
                  fileOrDirectory.fileCount,
                  fileOrDirectory.location,
                  fileOrDirectory.fullPath,
                  fileOrDirectory.remote,
                  fileOrDirectory.category,
                  fileOrDirectory.date);
          final int currentListIndex =
              fileListState.currentList.indexOf(fileOrDirectory);
          if (currentListIndex != -1) {
            fileListState.currentList[currentListIndex] = updatedFile;
          }
          extraFunctionCallback?.call();
          final AppService appService =
              Provider.of<AppService>(context, listen: false);
          Navigator.pop(context, "OK");
          LoadingOverlay.of(context).show();
          await appService.commandExecuter
              .rename(fileOrDirectory: fileOrDirectory, newName: data);
          LoadingOverlay.of(context).hide();
          showMessage(context: context, text: AppMessages.fileRename);
        } catch (e) {
          LoadingOverlay.of(context).hide();
          showMessage(context: context, text: AppMessages.errorOccurred);
          debugPrint('Error renaming file: $e');
        }
      },
      validator: valueNeeded,
      keyboardType: TextInputType.text,
      labelText: "New File Name",
      hintText: "File Rename",
    ),
  );
}
