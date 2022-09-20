import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:filesize/filesize.dart';

class FileObject {
  final File file;
  final String name;
  final int _size;
  final String extention;
  final String location;

  FileObject(this.file, this.name, this._size, this.extention, this.location);

  String get size => filesize(_size);
}

class FileManager {
  static const String downloadLocation = '/storage/emulated/0/Download';
  static const String galleryLocation = '/storage/emulated/0/Movies';
  static const String picturesLocation = '/storage/emulated/0/Pictures';
  static const String dcimLocation = '/storage/emulated/0/DCIM';
  static const String documentLocation = '/storage/emulated/0/Documents';
  static Directory downloadDir = Directory(downloadLocation);
  static Directory galleryDir = Directory(galleryLocation);
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

  static String getFileName(FileSystemEntity file) {
    return file.path.split('/').last.toString();
  }

  static String getExtention(FileSystemEntity file) {
    return getFileName(file).split('.').last.toUpperCase();
  }

  static int getFileSize(File file) {
    return file.lengthSync();
  }

  static bool checkExtention(File file) {
    return allowedMovieExtentions.contains(getExtention(file).toLowerCase());
  }

  static Future<List<FileObject>> getFiles(Directory directory) async {
    List<FileObject> files = [];
    if (await Permission.storage.request().isGranted &&
        directory.existsSync()) {
      final List<FileSystemEntity> fileEntities =
          directory.listSync(recursive: true).toList();
      final Iterable<File> filesIterable =
          fileEntities.whereType<File>().where((file) => checkExtention(file));
      for (File file in filesIterable) {
        files.add(FileObject(
            file,
            getFileName(file),
            getFileSize(file),
            getExtention(file),
            directory == downloadDir ? 'Downloads' : 'Gallery'));
      }
    }
    return files;
  }

  static Future<List<FileObject>> getAllFiles() async {
    List<FileObject> dowloadFiles = await getFiles(downloadDir);
    List<FileObject> galleryFiles = await getFiles(galleryDir);
    if (galleryFiles.isNotEmpty && dowloadFiles.isNotEmpty) {
      return dowloadFiles + galleryFiles;
    } else if (dowloadFiles.isEmpty) {
      return galleryFiles;
    } else {
      return dowloadFiles;
    }
  }
}
