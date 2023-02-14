// Flutter imports:
import 'package:flutter/material.dart';

class FolderConfigState with ChangeNotifier {
  bool addNewPath = false;
  int foldersCount = 0;
  FolderConfigState();

  void resetFolderCount() => foldersCount = 0;

  void incrementFolderCount() {
    foldersCount++;
    notifyListeners();
  }

  void decrementFolderCount() {
    foldersCount--;
    notifyListeners();
  }

  set setaddNewPath(bool addpath) {
    addNewPath = true;
    notifyListeners();
  }
}
