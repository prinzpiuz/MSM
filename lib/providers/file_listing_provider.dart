// Flutter imports:
import 'package:flutter/material.dart';
import 'package:msm/models/file_manager.dart';
import 'package:msm/models/folder_configuration.dart';

class FileListingState with ChangeNotifier {
  bool _searchMode = false;
  bool _applyFilter = false;
  String _nextPage = "";
  String _searchText = "";
  List<String> pathTraversed = [];
  List<FileOrDirectory> originalList = [];
  List<FileOrDirectory> currentList = [];
  List<FileOrDirectory> selectedList = [];
  late FolderConfiguration folderConfiguration;

  FileListingState();

  bool get isInSearchMode => _searchMode;
  bool get filterApplied => _applyFilter;
  String get nextPage => _nextPage;
  String get searchText => _searchText;

  set setSearchMode(bool searchMode) {
    _searchMode = searchMode;
    notifyListeners();
  }

  set applyFilter(bool applyFilter) {
    _applyFilter = applyFilter;
    notifyListeners();
  }

  void get turnOffFilter => _applyFilter = false;

  void selectOrRemoveItems(FileOrDirectory fileOrDirectory) {
    if (selectedList.contains(fileOrDirectory)) {
      selectedList.remove(fileOrDirectory);
    } else {
      selectedList.add(fileOrDirectory);
    }
  }

  void get clearSelection => {selectedList.clear(), notifyListeners()};

  set setSearchText(String searchText) {
    _searchText = searchText;
    notifyListeners();
  }

  set setNextPage(String page) {
    _nextPage = page;
    notifyListeners();
  }

  set addPath(String path) {
    pathTraversed.add(path);
  }

  void get popPath {
    if (pathTraversed.isNotEmpty) {
      pathTraversed.removeLast();
    }
  }

  String get lastPage {
    if (pathTraversed.isNotEmpty) {
      return pathTraversed.last;
    }
    return "";
  }

  bool get firstPage => pathTraversed.isEmpty;
}
