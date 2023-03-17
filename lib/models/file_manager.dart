// Dart imports:
import 'dart:io';

// Package imports:
import 'package:filesize/filesize.dart';

// Project imports:
import 'package:msm/providers/upload_provider.dart';

enum FileType { file, directory }

abstract class FileOrDirectory {
  String get name => '';
  String get location => '';
  String get size => '';
  String get extention => '';
  FileType get type => FileType.file;
  bool get isFile => type == FileType.file;
  int get fileCount => 0;
  String get fullPath => '';

  @override
  bool operator ==(other) {
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode => name.hashCode;
}

class FileObject extends FileOrDirectory {
  final File file;
  final String _name;
  final int _size;
  final String _extention;
  final String _location;
  final FileType _type;
  final String _fullPath;

  FileObject(this.file, this._name, this._size, this._extention, this._location,
      this._type, this._fullPath);

  @override
  String get name => _name;

  @override
  String get location => _location;

  @override
  String get extention => _extention;

  @override
  FileType get type => _type;

  @override
  String get size => filesize(_size);

  @override
  String get fullPath => _fullPath;
}

class DirectoryObject extends FileOrDirectory {
  final Directory directory;
  final String _name;
  final FileType _type;
  final int _fileCount;
  final String _location;

  DirectoryObject(
      this.directory, this._name, this._type, this._fileCount, this._location);

  @override
  String get name => _name;

  @override
  FileType get type => _type;

  @override
  int get fileCount => _fileCount;

  @override
  String get location => _location;
}

class FileManager {
  static const String downloadLocation = '/storage/emulated/0/Download';
  static const String galleryLocation = '/storage/emulated/0/Movies';
  static const String picturesLocation = '/storage/emulated/0/Pictures';
  static const String dcimLocation = '/storage/emulated/0/DCIM';
  static const String documentLocation = '/storage/emulated/0/Documents';
  static const String telegramLocation = '/storage/emulated/0/Telegram';

  static Directory downloadDir = Directory(downloadLocation);
  static Directory galleryDir = Directory(galleryLocation);
  static Directory picturesDir = Directory(picturesLocation);
  static Directory dcimDir = Directory(dcimLocation);
  static Directory documentDir = Directory(documentLocation);
  static Directory telegramDir = Directory(telegramLocation);
  static List<Directory> defaultDirectories = [
    downloadDir,
    galleryDir,
    picturesDir,
    dcimDir,
    documentDir,
    telegramDir
  ];
  static const List<String> allowedMovieExtentions = [
    'avi',
    'mkv',
    'srt',
    'mp4'
  ];

  static const List<String> allowedDocumentExtentions = [
    'pdf',
    'html',
    'azw',
    'mobi',
    'asw3',
    'epub'
  ];

  static const List<String> allowedPictureExtentions = [
    'jpeg',
    'jpg',
    'png',
    'gif',
    'tiff',
    'psd',
    'eps',
    'svg',
    'raw'
  ];

  static const List<String> allAllowedExtentions = [
    ...allowedDocumentExtentions,
    ...allowedMovieExtentions,
    ...allowedPictureExtentions
  ];

  static String getFileName(FileSystemEntity file) {
    return file.path.split('/').last.toString();
  }

  static String getDirectoryName(FileSystemEntity directory) {
    return directory.path.split('/').last.toString();
  }

  static String getExtention(FileSystemEntity file) {
    return getFileName(file).split('.').last.toUpperCase();
  }

  static int getFileSize(File file) {
    return file.lengthSync();
  }

  static Future<FileStat> getDirectorySize(Directory directory) {
    return directory.stat();
  }

  static bool checkExtention(File file, List<String> extentionList) {
    return extentionList.contains(getExtention(file).toLowerCase());
  }

  static String getFileLocation(Directory directory) {
    return directory.path.split("/").last.toString();
  }

  static Future<List<FileOrDirectory>> getFiles(
      Directory directory, UploadState uploadState) async {
    List<FileOrDirectory> files = [];
    if (directory.existsSync()) {
      final List<FileSystemEntity> fileEntities = directory.listSync().toList();
      final Iterable<File> filesIterable = fileEntities.whereType<File>().where(
          (file) => checkExtention(file, uploadState.getCategoryExtentions));
      final Iterable<Directory> directoryIterables =
          fileEntities.whereType<Directory>();
      for (Directory directory in directoryIterables) {
        files.add(DirectoryObject(directory, getDirectoryName(directory),
            FileType.directory, directoryIterables.length, directory.path));
      }
      for (File file in filesIterable) {
        files.add(FileObject(
            file,
            getFileName(file),
            getFileSize(file),
            getExtention(file),
            getFileLocation(directory),
            FileType.file,
            "${directory.path}/${getFileName(file)}"));
      }
    }
    return files;
  }

  static Future<List<FileOrDirectory>> getAllFiles(
      UploadState uploadState) async {
    List<FileOrDirectory> allFiles = [];
    if (uploadState.getRecursive &&
        uploadState.getNextFilesDirectory.isNotEmpty) {
      allFiles.addAll(
          await getFiles(uploadState.getNextFilesDirectory.last, uploadState));
    } else {
      for (Directory dir in uploadState.getCategoryDirectories) {
        allFiles.addAll(await getFiles(dir, uploadState));
      }
    }

    return allFiles;
  }

  static String pathBuilder(List<String> path) {
    if (path.isNotEmpty) {
      return path.join("/");
    }
    return "";
  }
}
