// Flutter imports:
import 'package:flutter/material.dart';

class FileListingState with ChangeNotifier {
  bool _searchMode = false;
  String _nextPage = "";
  List<String> pathTraversed = [];

  FileListingState();

  bool get isInSearchMode => _searchMode;
  String get nextPage => _nextPage;

  set setSearchMode(bool searchMode) {
    _searchMode = searchMode;
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
