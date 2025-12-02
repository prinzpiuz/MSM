// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dartssh2/dartssh2.dart';

import 'package:msm/constants/constants.dart' show ShellScriptPaths;
// Project imports:
import 'package:msm/utils.dart';
import 'package:msm/utils/commands/basic_details.dart';
import 'package:msm/utils/commands/commands.dart';
import 'package:msm/utils/commands/services.dart';
import 'package:msm/utils/file_manager.dart';
import 'package:msm/utils/folder_configuration.dart';
import 'package:msm/utils/local_notification.dart';
import 'package:msm/utils/server.dart';
import 'package:msm/views/upload_pages/upload_page_utils.dart';

class CommandExecuter extends Server {
  late SSHClient? client;
  late SftpClient? sftp;
  late Notifications? notifications;
  CommandExecuter({
    required super.serverData,
    required super.folderConfiguration,
    required super.serverFunctionsData,
    required this.client,
    required this.sftp,
    required this.notifications,
  });

  Future<BasicDetails?> get basicDetails async {
    try {
      final script = await loadShellScript(ShellScriptPaths.basicDetails);
      if (client != null) {
        final basicDetails = decodeOutput(await client!.run(script));
        return BasicDetails(basicDetails);
      }
    } catch (_) {
      super.state = ServerState.disconnected;
    }
    return null;
  }

  Future<List<FileOrDirectory>?>? listRemoteDirectory(
      UploadCatogories catogory, String? insidePath,
      {bool empty = false, String customPath = ""}) async {
    List<FileOrDirectory> directories = [];
    if (empty) {
      return directories;
    } else {
      try {
        String? directory = super.folderConfiguration.pathToDirectory(catogory);
        if (catogory == UploadCatogories.custom && customPath.isNotEmpty) {
          directory = customPath;
        }
        if (directory != null && sftp != null) {
          if (insidePath != null) {
            directory = "$directory/$insidePath";
          }
          final items = await sftp!.listdir(directory);
          for (final item in items) {
            if (item.attr.isDirectory &&
                (item.filename != "." && item.filename != "..")) {
              String filepath = FileManager.linuxCompatibleNameString(
                  "$directory/${item.filename}");
              directories.add(DirectoryObject(
                  Directory(filepath),
                  item.filename,
                  item.attr.size ?? 0,
                  FileType.directory,
                  0, //intentionally put to zero because it does'nt matter at the moment
                  directory,
                  filepath,
                  true,
                  null, //file category does'nt matter here
                  item.attr.modifyTime ??
                      0)); //file category does'nt matter here
            }
          }
        }
        return directories;
      } catch (_) {
        return null;
      }
    }
  }

  Future<List<FileOrDirectory>> listAllRemoteDirectories(
      {required String path}) async {
    if (sftp == null) return [];

    final pathsToList = _getPathsToList(path);
    if (pathsToList.isEmpty) return [];

    try {
      final futures = pathsToList.map((p) => sftp!.listdir(p));
      final results = await Future.wait(futures);

      final items = <FileOrDirectory>{}; // Use Set to avoid duplicates

      for (int i = 0; i < results.length; i++) {
        final currentPath = pathsToList[i];
        final dirItems = results[i];

        for (final item in dirItems) {
          if (item.filename == '.' || item.filename == '..') continue;

          final fullPath = FileManager.linuxCompatibleNameString(
              '$currentPath/${item.filename}');
          final extension = item.filename.split('.').last;
          final fileCategory = FileCategory.getCategoryFromExtension(extension);
          final modifyTime = item.attr.modifyTime ?? 0;

          if (item.attr.isDirectory) {
            items.add(DirectoryObject(
              Directory(fullPath),
              item.filename,
              item.attr.size ?? 0,
              FileType.directory,
              0, // Intentionally zero as it doesn't matter
              currentPath,
              fullPath,
              true,
              fileCategory,
              modifyTime,
            ));
          } else {
            items.add(FileObject(
              File(fullPath),
              item.filename,
              item.attr.size ?? 0,
              extension,
              currentPath,
              FileType.file,
              fullPath,
              true,
              fileCategory,
              modifyTime,
            ));
          }
        }
      }

      return items.toList();
    } on SftpStatusError catch (_) {
      // Handle SFTP-specific errors gracefully
      return [];
    } catch (_) {
      // Handle other unexpected errors
      return [];
    }
  }

  List<String> _getPathsToList(String path) {
    final paths = <String>[];
    if (path.isNotEmpty) {
      paths.add(path);
    } else {
      if (super.folderConfiguration.dataAvailable) {
        paths.addAll([
          super.folderConfiguration.movies,
          super.folderConfiguration.tv,
          super.folderConfiguration.books,
        ]);
      }
      paths.addAll(super.folderConfiguration.customFolders);
    }
    paths.removeWhere((element) => element.isEmpty);
    return paths;
  }

  Future<void> delete(
      {required List<FileOrDirectory> fileOrDirectories}) async {
    try {
      for (FileOrDirectory fileOrDirectory in fileOrDirectories) {
        if (fileOrDirectory.isFile) {
          await sftp!.remove(fileOrDirectory.fullPath);
        } else {
          await sftp!.rmdir(fileOrDirectory.fullPath);
        }
      }
    } catch (_) {
      //this is implemented because for avoid delete error `SftpStatusError`
      // in some files with spaces or special chars in file name
      List<String> pathList = [];
      for (FileOrDirectory fileOrDirectory in fileOrDirectories) {
        pathList.add(fileOrDirectory.fullPath);
      }
      String command =
          CommandBuilder.addArguments(Commands.deleteFileOrFolders, pathList);
      client!.execute(command);
    }
  }

  Future<void> rename(
      {required FileOrDirectory fileOrDirectory,
      required String newName}) async {
    String newPath = FileManager.linuxCompatibleNameString(
        "${fileOrDirectory.location}/$newName");
    try {
      await sftp!.rename(fileOrDirectory.fullPath, newPath);
    } catch (_) {
      //this is implemented because for avoid delete error `SftpStatusError`
      // in some files with spaces or special chars in file name
      String command = CommandBuilder.addArguments(
          Commands.rename, [fileOrDirectory.fullPath, newPath]);
      client!.execute(command);
    }
  }

  Future<void> move(
      {required FileOrDirectory fileOrDirectory,
      required String newLocation}) async {
    String newPath = FileManager.linuxCompatibleNameString(newLocation);
    try {
      String command = CommandBuilder.addArguments(
          Commands.rename, [fileOrDirectory.fullPath, newPath]);
      client!.execute(command);
    } catch (_) {}
  }

  Future<String> base64({required FileOrDirectory fileOrDirectory}) async {
    try {
      String command = CommandBuilder.addArguments(
          Commands.base64, [fileOrDirectory.fullPath]);
      final String encodedString = decodeOutput(await client!.run(command));
      return encodedString;
    } catch (_) {
      return "";
    }
  }

  /// Retrieves the list of available system services.
  ///
  /// Parses the output of the systemctl command to extract service information.
  /// Returns an empty list if parsing fails or no services are found.
  Future<List<Services>> availableServices() async {
    final List<Services> services = [];
    try {
      const String command = Commands.getServices;
      final String output = decodeOutput(await client!.run(command));
      final List<String> lines = output.split('end');
      if (lines.isEmpty) return services;

      // Skip header (index 0) and footer (last 9 lines based on command output structure)
      const int headerOffset = 1;
      const int footerOffset = 9;
      final int startIndex = headerOffset;
      final int endIndex = lines.length - footerOffset;
      if (startIndex >= endIndex || endIndex <= 0) return services;

      final List<String> serviceLines = lines.sublist(startIndex, endIndex);
      for (final String line in serviceLines) {
        final Services? service = _parseServiceLine(line);
        if (service != null) {
          services.add(service);
        }
      }
    } catch (e) {
      // Return empty list on any error to maintain consistency
      return [];
    }
    return services;
  }

  /// Parses a single service line into a Services object.
  ///
  /// Expects the line to be comma-separated with at least 4 parts:
  /// unit, load, active_sub, description
  Services? _parseServiceLine(String line) {
    final List<String> parts = line.split(',');
    if (parts.length < 4) return null;
    return Services(
      unit: parts[0].trim(),
      serviceStatus: parts[2].trim(),
      description: parts[3].trim(),
    );
  }

  /// Performs a speed test using speedtest-cli.
  ///
  /// Returns a [Speed] object with parsed results if successful,
  /// a string error message if the command is not found,
  /// or null if an unexpected error occurs.
  Future<dynamic> speedTest() async {
    try {
      const String command = Commands.speedTest;
      final String output = decodeOutput(await client!.run(command));
      if (output.contains('command not found')) {
        return 'Command not found. Please install speedtest-cli from https://www.speedtest.net/apps/cli';
      }
      return Speed(commandOutput: output);
    } on FormatException catch (e) {
      // Handle JSON parsing errors specifically
      return 'Failed to parse speed test output: ${e.message}';
    } catch (e) {
      // Handle other unexpected errors
      return null;
    }
  }

  Future<Map<String, dynamic>> foldersExist(
      FolderConfiguration folderConfigurationObj) async {
    if (!folderConfigurationObj.dataAvailable ||
        folderConfigurationObj.allPaths.isEmpty) {
      return {"status": true, "notExist": <String>[]};
    }

    final allFolders = folderConfigurationObj.allPaths;

    // Run existence checks in parallel for better performance
    final futures = allFolders.map((folder) async {
      try {
        final command = Commands.folderExist(folder);
        final output = decodeOutput(await client!.run(command));
        return output.contains("Exists");
      } catch (_) {
        // On error, assume folder does not exist
        return false;
      }
    });

    final existStatuses = await Future.wait(futures);

    // Collect non-existent folders
    final nonExistentFolders = <String>[];
    for (int i = 0; i < allFolders.length; i++) {
      if (!existStatuses[i]) {
        nonExistentFolders.add(allFolders[i]);
      }
    }

    final allExist = nonExistentFolders.isEmpty;
    return {"status": allExist, "notExist": nonExistentFolders};
  }
}
