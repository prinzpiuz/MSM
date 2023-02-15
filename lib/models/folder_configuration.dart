class FolderConfiguration {
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
