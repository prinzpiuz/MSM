// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';
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
        return "TV";
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
