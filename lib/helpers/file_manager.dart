import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class Storage {
  static const String downloadDirectory = '/storage/emulated/0';
  static const String galleryMoviesDirectory = '/storage/emulated/Movies';
  Directory dir = Directory(downloadDirectory);
}
