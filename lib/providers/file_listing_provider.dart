// Flutter imports:
import 'package:flutter/material.dart';
import 'package:msm/models/file_manager.dart';

class FileListingState with ChangeNotifier {
  bool _searchMode = false;
  String _nextPage = "";
  String _searchText = "";
  List<String> pathTraversed = [];
  List<FileOrDirectory> currentList = [];

  FileListingState();

  bool get isInSearchMode => _searchMode;
  String get nextPage => _nextPage;
  String get searchText => _searchText;

  set setSearchMode(bool searchMode) {
    _searchMode = searchMode;
    notifyListeners();
  }

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
