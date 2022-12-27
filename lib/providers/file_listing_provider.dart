// Flutter imports:
import 'package:flutter/material.dart';

class FileListingState with ChangeNotifier {
  bool _searchMode = false;
  FileListingState();
  bool get isInSearchMode => _searchMode;

  set setSearchMode(bool searchMode) {
    _searchMode = searchMode;
    notifyListeners();
  }
}
