import 'dart:io';

import 'package:flutter/material.dart';
import 'package:msm/models/file_manager.dart';
import 'package:msm/views/upload_pages/upload_page_utils.dart';

class UploadState with ChangeNotifier {
  UploadCatogories _category = UploadCatogories.movies;
  List<String> _categoryExtentions = FileManager.allowedMovieExtentions;
  String _currentListing = UploadCatogories.movies.getTitle;
  final List<Directory> _directories = FileManager.defaultDirectories;

  UploadState();

  UploadCatogories get getCategory => _category;
  List<String> get getCategoryExtentions => _categoryExtentions;
  List<Directory> get getCategoryDirectories => _directories;
  String get getCurrentListing => _currentListing;

  set setCategory(UploadCatogories currentCategory) {
    _category = currentCategory;
    notifyListeners();
  }

  set setCategoryExtentions(List<String> currentCategoryExtentions) {
    _categoryExtentions = currentCategoryExtentions;
    notifyListeners();
  }

  set setCurrentListing(String currentCategory) {
    _currentListing = currentCategory;
  }
}
