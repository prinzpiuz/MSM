// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:msm/models/file_manager.dart';
import 'package:msm/models/folder_configuration.dart';

class FileListingState with ChangeNotifier {
  bool _searchMode = false;
  bool _applyFilter = false;
  bool _isLoading = false;
  String _nextPage = "";
  String _searchText = "";
  List<String> pathTraversed = [];
  List<FileOrDirectory> originalList = [];
  List<FileOrDirectory> currentList = [];
  List<FileOrDirectory> selectedList = [];
  late FolderConfiguration folderConfiguration;
  late GestureDetector fabGestureDetector;
  late bool fabOpen;

  FileListingState();

  bool get isInSearchMode => _searchMode;
  bool get filterApplied => _applyFilter;
  bool get isLoading => _isLoading;
  String get nextPage => _nextPage;
  String get searchText => _searchText;

  set setSearchMode(bool searchMode) {
    _searchMode = searchMode;
    notifyListeners();
  }

  set setIsLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  set applyFilter(bool applyFilter) {
    _applyFilter = applyFilter;
    notifyListeners();
  }

  void get cancelModes => _applyFilter = _searchMode = false;

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

  void get clearSearchText => _searchText = "";

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
