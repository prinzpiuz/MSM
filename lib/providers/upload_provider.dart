// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:msm/models/file_manager.dart';
import 'package:msm/views/upload_pages/upload_page_utils.dart';

class UploadState with ChangeNotifier {
  UploadCatogories _category = UploadCatogories.movies;
  List<String> _categoryExtentions = FileManager.allowedMovieExtentions;
  String _currentListing = UploadCatogories.movies.getTitle;
  bool _recursive = false;
  final List<Directory> _nextFilesDirectory = [];
  final List<Directory> _directories = FileManager.defaultDirectories;

  UploadState();

  UploadCatogories get getCategory => _category;
  List<String> get getCategoryExtentions => _categoryExtentions;
  List<Directory> get getCategoryDirectories => _directories;
  String get getCurrentListing => _currentListing;
  bool get getRecursive => _recursive;
  List<Directory> get getNextFilesDirectory => _nextFilesDirectory;

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

  set setRecursive(bool recursive) {
    _recursive = recursive;
  }

  set setNextFilesDirectory(Directory nextDirectory) {
    _nextFilesDirectory.add(nextDirectory);
  }

  popLastDirectory() {
    if (_nextFilesDirectory.isNotEmpty) {
      _nextFilesDirectory.removeLast();
    } else {
      _recursive = false;
    }
    notifyListeners();
  }
}
