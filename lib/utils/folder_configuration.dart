// Project imports:
import 'package:msm/views/upload_pages/upload_page_utils.dart';

class FolderConfiguration {
  String movies;
  String tv;
  String books;
  List<String> customFolders;

  FolderConfiguration(
      {this.movies = "",
      this.tv = "",
      this.books = "",
      this.customFolders = const []});

  void addExtraFolder(String path) {
    if (!customFolders.contains(path)) {
      customFolders.add(path);
    }
  }

  void removeExtraFolder(int index) {
    customFolders.removeAt(index);
  }

  String? pathToDirectory(UploadCatogories catogories) {
    switch (catogories) {
      case UploadCatogories.movies:
        return movies;
      case UploadCatogories.tvShows:
        return tv;
      case UploadCatogories.books:
        return books;
      case UploadCatogories.custom:
        return "custom";
    }
  }

  bool get dataAvailable {
    if (movies.isNotEmpty ||
        tv.isNotEmpty ||
        books.isNotEmpty ||
        customFolders.isNotEmpty) {
      return true;
    }
    return false;
  }

  List<String> get allPaths {
    List<String> allFolders = [];
    if (movies.isNotEmpty) {
      allFolders.add(movies);
    }
    if (tv.isNotEmpty) {
      allFolders.add(tv);
    }
    if (books.isNotEmpty) {
      allFolders.add(books);
    }
    if (customFolders.isNotEmpty) {
      allFolders.addAll(customFolders);
    }
    return allFolders;
  }

  FolderConfiguration.fromJson(Map<String, dynamic> json)
      : movies = json['movies'],
        tv = json['tv'],
        books = json['books'],
        customFolders = json['customFolders'].cast<String>();

  Map<String, dynamic> toJson() => {
        'movies': movies,
        'tv': tv,
        'books': books,
        'customFolders': customFolders
      };
}
