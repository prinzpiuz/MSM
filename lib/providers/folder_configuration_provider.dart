// Flutter imports:
import 'package:flutter/material.dart';

class FolderConfigState with ChangeNotifier {
  bool addNewPath = false;
  int foldersCount = 0;
  List<Widget> pathTextFields = [];
  FolderConfigState();

  void resetFolderCount() => foldersCount = 0;

  void removeFromWidgetList(int index) {
    pathTextFields.removeAt(index);
    foldersCount--;
    notifyListeners();
  }

  void incrementFolderCount() {
    foldersCount++;
    notifyListeners();
  }

  void decrementFolderCount() {
    foldersCount--;
    notifyListeners();
  }

  set setAddNewPath(bool addpath) {
    addNewPath = true;
    notifyListeners();
  }
}
