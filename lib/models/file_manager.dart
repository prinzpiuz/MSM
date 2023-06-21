// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:filesize/filesize.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:msm/constants/colors.dart';
import 'package:msm/providers/upload_provider.dart';

enum FileType { file, directory }

enum FileCategory {
  movieOrTv,
  book,
  subtitle,
  image,
  unknown;

  Icon categoryIcon(bool selected) {
    switch (this) {
      case FileCategory.movieOrTv:
        return leadingIcon(FontAwesomeIcons.film, selected);
      case FileCategory.book:
        return leadingIcon(FontAwesomeIcons.bookOpenReader, selected);
      case FileCategory.subtitle:
        return leadingIcon(FontAwesomeIcons.closedCaptioning, selected);
      case FileCategory.image:
        return leadingIcon(FontAwesomeIcons.fileImage, selected);
      case FileCategory.unknown:
        return leadingIcon(FontAwesomeIcons.question, selected);
    }
  }

  static FileCategory getCategoryFromExtention(String extention) {
    if (FileManager.allowedMovieExtentions.contains(extention)) {
      return movieOrTv;
    } else if (FileManager.allowedDocumentExtentions.contains(extention)) {
      return book;
    } else if (FileManager.allowedPictureExtentions.contains(extention)) {
      return image;
    } else if (FileManager.allowedSubtitlesExtentions.contains(extention)) {
      return subtitle;
    }
    return unknown;
  }
}

Icon leadingIcon(IconData icon, bool selected) {
  return Icon(icon,
      color: selected
          ? CommonColors.commonGreenColor
          : CommonColors.commonBlackColor);
}

abstract class FileOrDirectory {
  String get name => '';
  String get location => '';
  String get size => '';
  String get extention => '';
  FileType get type => FileType.file;
  bool get isFile => type == FileType.file;
  int get fileCount => 0;
  String get fullPath => '';
  bool get remote => false;
  FileCategory? category;
  int get date => 0;

  @override
  bool operator ==(other) {
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode => name.hashCode;

  String get dateInFormat {
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(date * 1000);
    int day = datetime.day;
    int month = datetime.month;
    int year = datetime.year;
    return "$day-$month-$year";
  }
}

class FileObject extends FileOrDirectory {
  final File file;
  final String _name;
  final int _size;
  final String _extention;
  final String _location;
  final FileType _type;
  final String _fullPath;
  final bool _remoteFile;
  final FileCategory? _category;
  final int _date;

  FileObject(this.file, this._name, this._size, this._extention, this._location,
      this._type, this._fullPath, this._remoteFile, this._category, this._date);

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

  @override
  bool get remote => _remoteFile;

  @override
  FileCategory? get category => _category;

  @override
  int get date => _date;
}

class DirectoryObject extends FileOrDirectory {
  final Directory directory;
  final String _name;
  final int _size;
  final FileType _type;
  final int _fileCount;
  final String _location;
  final String _fullPath;
  final bool _remoteDirectory;
  final FileCategory? _category;
  final int _date;

  DirectoryObject(
      this.directory,
      this._name,
      this._size,
      this._type,
      this._fileCount,
      this._location,
      this._fullPath,
      this._remoteDirectory,
      this._category,
      this._date);

  @override
  String get name => _name;

  @override
  FileType get type => _type;

  @override
  int get fileCount => _fileCount;

  @override
  String get location => _location;

  @override
  bool get remote => _remoteDirectory;

  @override
  FileCategory? get category => _category;

  @override
  String get size => filesize(_size);

  @override
  String get fullPath => _fullPath;

  @override
  int get date => _date;
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
    'mp4',
    ...allowedSubtitlesExtentions
  ];

  static const List<String> allowedSubtitlesExtentions = ["srt"];

  static const List<String> allowedDocumentExtentions = [
    'pdf',
    'html',
    'azw',
    'mobi',
    'azw3',
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

  static String linuxCompatibleNameString(String name) {
    //to change filenames to linux compatible string
    //eg: Mr. Brooks (2007) => Mr.\ Brooks\ \(2007\)
    List<String> watchLetters = ["(", ")", "[", "]", "{", "}", "'"];
    List<String> letters = name.split("");
    int count = 0;
    for (var i = 0; i < name.length; i++) {
      if (name[i] == " ") {
        letters.insert(i + count, '\\');
        count++;
      }
      if (watchLetters.contains(name[i])) {
        letters.insert(i + count, '\\');
        count++;
      }
    }
    return letters.join();
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
        files.add(DirectoryObject(
            directory,
            getDirectoryName(directory),
            0, //does'nt matter folder size in files from phone storage
            FileType.directory,
            directoryIterables.length,
            directory.path,
            "${directory.path}/${getDirectoryName(directory)}",
            false,
            null,
            0)); //file category does'nt matter here
      }
      for (File file in filesIterable) {
        files.add(FileObject(
            file,
            getFileName(file),
            getFileSize(file),
            getExtention(file),
            getFileLocation(directory),
            FileType.file,
            "${directory.path}/${getFileName(file)}",
            false,
            null,
            file
                .lastModifiedSync()
                .millisecondsSinceEpoch)); //file category does'nt matter here
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
