// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/models/file_manager.dart';
import 'package:msm/providers/file_listing_provider.dart';
import 'package:msm/ui_components/textfield/textfield.dart';

PreferredSizeWidget searchBar(
    //TODO may be look here for more implementation related helps https://pub.dev/packages/app_bar_with_search_switch/example
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
  moviesOnly,
  tvOnly,
  booksOnly,
  subtitlesOnly,
  deleteSelected,
  sizeCalculation,
  hiddenFiles;

  String get menuText {
    switch (this) {
      case FileListPopMenu.moviesOnly:
        return "Movies";
      case FileListPopMenu.tvOnly:
        return "TV Shows";
      case FileListPopMenu.booksOnly:
        return "Books";
      case FileListPopMenu.subtitlesOnly:
        return "Subtitles";
      case FileListPopMenu.deleteSelected:
        return "Delete Selected";
      case FileListPopMenu.sizeCalculation:
        return "Calculate Size";
      case FileListPopMenu.hiddenFiles:
        return "Show Hidden";
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
