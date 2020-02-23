class TvFolders {
  final List<dynamic> folders;

  TvFolders({this.folders});

  factory TvFolders.fromJson(Map<String, dynamic> json) {
    return TvFolders(
      folders: json['folders'],
    );
  }
}
