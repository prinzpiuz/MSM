// Project imports:
import 'package:msm/views/upload_pages/upload_page_utils.dart';

class FolderConfiguration {
  //TODO need to check folders exist before saving
  String? movies;
  String? tv;
  String? books;
  List<dynamic> customFolders;

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
    //TODO implement a logic to get the correct path to custom folders
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

  FolderConfiguration.fromJson(Map<String, dynamic> json)
      : movies = json['movies'],
        tv = json['tv'],
        books = json['books'],
        customFolders = json['customFolders'];

  Map<String, dynamic> toJson() => {
        'movies': movies,
        'tv': tv,
        'books': books,
        'customFolders': customFolders
      };
}
