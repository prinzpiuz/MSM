// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:msm/common_utils.dart';
import 'package:msm/common_widgets.dart';

// Project imports:
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/context_keys.dart';
import 'package:msm/models/file_manager.dart';
import 'package:msm/providers/file_listing_provider.dart';
import 'package:msm/ui_components/text/textstyles.dart';
import 'package:msm/ui_components/textfield/textfield.dart';

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
    elevation: AppFontSizes.appBarElevation,
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
  deleteSelected,
  sizeCalculation;

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
      case FileListPopMenu.deleteSelected:
        return "Delete Selected";
      case FileListPopMenu.sizeCalculation:
        return "Calculate Size";
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
      case FileListPopMenu.deleteSelected:
        return deletedSelected(listingState);
      case FileListPopMenu.sizeCalculation:
        break;
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

void deletedSelected(FileListingState listingState) {
  BuildContext context = ContextKeys.fileListingPageKey.currentContext!;
  dailogBox(
    context: context,
    content: SizedBox(
      height: AppFontSizes.deleteFileDailogBoxHeight.h *
          listingState.selectedList.length,
      child: ListView.separated(
        separatorBuilder: (context, index) => commonDivider,
        itemCount: listingState.selectedList.length,
        itemBuilder: (BuildContext context, int index) {
          return Text(
            listingState.selectedList[index].name,
            style: AppTextStyles.regular(CommonColors.commonBlackColor, 12.sp),
          );
        },
      ),
    ),
    okOnPressed: () {
      print("Deleting");
      Navigator.pop(context, "OK");
    },
    title: AppConstants.deleteFilesTitle,
  );
}
