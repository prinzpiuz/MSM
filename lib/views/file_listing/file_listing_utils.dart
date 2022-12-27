// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/font_sizes.dart';
import 'package:msm/providers/file_listing_provider.dart';
import 'package:msm/views/ui_components/textfield/textfield.dart';

PreferredSizeWidget searchBar(
    //TODO may be look here for more implementation related helps https://pub.dev/packages/app_bar_with_search_switch/example
    {required TextEditingController searchController,
    required FileListingState listingState}) {
  return AppBar(
    title: AppTextField.simpleTextField(controller: searchController),
    elevation: AppConstants.appBarElevation,
    backgroundColor: CommonColors.commonWhiteColor,
    leading: Padding(
      padding: EdgeInsets.only(left: 10.w, bottom: 10.h, top: 10.h),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: CommonColors.commonBlackColor,
          size: AppFontSizes.appBarIconSize.sp,
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

//todo will need to change the type of this function to corresponding model while doing real implementation
String generateSubtitle(fileItem) {
  String size = fileItem["size"];
  String extention = fileItem["extention"];
  String date = fileItem["date"];
  return "$size, $extention, $date";
}

enum FileCategory {
  movie,
  tv,
  book,
  subtitle,
  image;

  Icon get categoryIcon {
    switch (this) {
      case FileCategory.movie:
        return leadingIcon(FontAwesomeIcons.film);
      case FileCategory.tv:
        return leadingIcon(FontAwesomeIcons.folder);
      case FileCategory.book:
        return leadingIcon(FontAwesomeIcons.bookOpenReader);
      case FileCategory.subtitle:
        return leadingIcon(FontAwesomeIcons.closedCaptioning);
      case FileCategory.image:
        return leadingIcon(FontAwesomeIcons.fileImage);
      default:
        return leadingIcon(FontAwesomeIcons.question);
    }
  }
}

Icon leadingIcon(IconData icon) {
  return Icon(icon, color: CommonColors.commonBlackColor);
}
