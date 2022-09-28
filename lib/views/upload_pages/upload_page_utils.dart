// Flutter imports:
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/models/file_manager.dart';
import 'package:msm/providers/upload_provider.dart';

// Project imports:
import 'package:msm/router/router_utils.dart';
import 'package:provider/provider.dart';

enum UploadCatogories { movies, tvShows, books, pictures }

extension UploadCategoriesExtention on UploadCatogories {
  String get getTitle {
    switch (this) {
      case UploadCatogories.movies:
        return "Movies";
      case UploadCatogories.tvShows:
        return "TV Shows";
      case UploadCatogories.books:
        return "Books";
      case UploadCatogories.pictures:
        return "Pictures";
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
    case UploadCatogories.pictures:
      uploadState.setCategory = UploadCatogories.pictures;
      uploadState.setCategoryExtentions = FileManager.allowedPictureExtentions;
      uploadState.setCurrentListing = UploadCatogories.pictures.getTitle;
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

Future<void> bottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 300.h,
        color: CommonColors.commonWhiteColor,
        child: ListView.builder(
          itemCount: 25,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text('Item $index'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => print("object"),
              ),
            );
          },
        ),
      );
    },
  );
}
