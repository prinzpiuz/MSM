// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dartssh2/dartssh2.dart';

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
      String command = CommandBuilder().andAll(Commands.basicDetailsGroup);
      if (client != null) {
        final basicDetails = decodeOutput(await client!.run(command));
        return BasicDetails(BasicDetails.mapSource(basicDetails));
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
          CommandBuilder().addArguments(Commands.deleteFileOrFolders, pathList);
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
      String command = CommandBuilder()
          .addArguments(Commands.rename, [fileOrDirectory.fullPath, newPath]);
      client!.execute(command);
    }
  }

  Future<void> move(
      {required FileOrDirectory fileOrDirectory,
      required String newLocation}) async {
    String newPath = FileManager.linuxCompatibleNameString(newLocation);
    try {
      String command = CommandBuilder()
          .addArguments(Commands.rename, [fileOrDirectory.fullPath, newPath]);
      client!.execute(command);
    } catch (_) {}
  }

  Future<String> base64({required FileOrDirectory fileOrDirectory}) async {
    try {
      String command = CommandBuilder()
          .addArguments(Commands.base64, [fileOrDirectory.fullPath]);
      final String encodedString = decodeOutput(await client!.run(command));
      return encodedString;
    } catch (_) {
      return "";
    }
  }

  Future<List<Services>> availableServices() async {
    List<Services> serviceList = [];
    try {
      String command = Commands.getServices;
      String output = decodeOutput(await client!.run(command));
      List<String> splitAtEnd = output.split("end");
      if (splitAtEnd.isNotEmpty) {
        List<String> wantedServices =
            splitAtEnd.sublist(1, splitAtEnd.length - 9);
        for (String item in wantedServices) {
          List individualService = item.split(",");
          serviceList.add(Services(
              unit: individualService[0].trim(),
              serviceStatus: individualService[2].trim(),
              description: individualService[3].trim()));
        }
      }
      return serviceList;
    } catch (_) {
      return serviceList;
    }
  }

  Future<dynamic> speedTest() async {
    try {
      String command = Commands.speedTest;
      String output = decodeOutput(await client!.run(command));
      if (output.contains("command not found")) {
        return "$output"
            "\n Please Install speedtest-cli \n https://www.speedtest.net/apps/cli";
      }
      return Speed(commandOutput: output);
    } catch (_) {
      return null;
    }
  }

  Future<Map> foldersExist(FolderConfiguration folderConfigurationObj) async {
    Map status = {"status": "", "notExist": ""};
    try {
      List<String> allFolders = [];
      List<bool> folderExistStatus = [];
      List<String> foldersNotExist = [];
      if (folderConfigurationObj.dataAvailable) {
        allFolders.addAll([
          folderConfigurationObj.movies,
          folderConfigurationObj.tv,
          folderConfigurationObj.books,
        ]);
      }
      if (folderConfigurationObj.customFolders.isNotEmpty) {
        allFolders.addAll(folderConfigurationObj.customFolders);
      }
      for (String folder in allFolders) {
        String command = Commands.folderExist(folder);
        String existStatus = decodeOutput(await client!.run(command));
        if (existStatus.contains("Not found")) {
          folderExistStatus.add(false);
          foldersNotExist.add(folder);
        }
        if (existStatus.contains("Exists")) {
          folderExistStatus.add(true);
        }
      }
      if (folderExistStatus.contains(false)) {
        status.update("status", (value) => false);
        status.update("notExist", (value) => foldersNotExist);
      } else {
        status.update("status", (value) => true);
        status.update("notExist", (value) => foldersNotExist);
      }
      return status;
    } catch (_) {
      return status;
    }
  }
}
