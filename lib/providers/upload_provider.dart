// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:msm/models/file_manager.dart';
import 'package:msm/models/file_upload.dart';
import 'package:msm/views/upload_pages/upload_page_utils.dart';

class UploadState with ChangeNotifier {
  UploadCatogories _category = UploadCatogories.movies;
  List<String> _categoryExtensions = FileManager.allowedMovieExtensions;
  String _currentListing = UploadCatogories.movies.getTitle;
  bool _recursive = false;
  String newFolderName = "";
  bool empty = false;
  bool toCustomFolder = false;
  String customPath = "";
  final List<Directory> _nextFilesDirectory = [];
  final List<Directory> _directories = FileManager.defaultDirectories;
  final FileUploadData fileUploadData = FileUploadData();
  final List<String> _trackRemoteDirectory = [];
  final List<String> _newFolders = [];

  UploadState();

  UploadCatogories get getCategory => _category;
  List<String> get getCategoryExtensions => _categoryExtensions;
  List<Directory> get getCategoryDirectories => _directories;
  String get getCurrentListing => _currentListing;
  bool get getRecursive => _recursive;
  List<Directory> get getNextFilesDirectory => _nextFilesDirectory;
  List<String> get traversedDirectories => _trackRemoteDirectory;
  List<String> get newFoldersToCreate => _newFolders;

  set setCategory(UploadCatogories currentCategory) {
    _category = currentCategory;
    notifyListeners();
  }

  set setCategoryExtensions(List<String> currentCategoryExtensions) {
    _categoryExtensions = currentCategoryExtensions;
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

  void addRemoteDirectoru(String directory) {
    if (directory.isNotEmpty) {
      _trackRemoteDirectory.add(directory);
    }
  }

  void addNewFolderName(String name) {
    if (name.isNotEmpty) {
      _newFolders.add(name);
    }
  }

  void get clearNewFolder => _newFolders.clear();

  void get clearPaths => _trackRemoteDirectory.clear();

  void popLastDirectory() {
    if (_nextFilesDirectory.isNotEmpty) {
      _nextFilesDirectory.removeLast();
    } else {
      _recursive = false;
    }
    notifyListeners();
  }

  void get fileAddOrRemove {
    notifyListeners();
  }

  void get commonClear {
    clearPaths;
    empty = false;
    clearNewFolder;
  }

  void get commonCalls {
    commonClear;
    fileUploadData.clear;
    popLastDirectory();
  }
}
