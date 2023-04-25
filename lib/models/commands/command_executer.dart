// Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// Package imports:
import 'package:dartssh2/dartssh2.dart';

// Project imports:
import 'package:msm/constants/constants.dart';
import 'package:msm/models/commands/basic_details.dart';
import 'package:msm/models/commands/commands.dart';
import 'package:msm/models/file_manager.dart';
import 'package:msm/models/local_notification.dart';
import 'package:msm/models/server.dart';
import 'package:msm/views/upload_pages/upload_page_utils.dart';

class CommandExecuter extends Server {
  late SSHClient? client;
  late SftpClient? sftp;
  late Notifications? notifications;
  CommandExecuter(
      {required super.serverData,
      required super.folderConfiguration,
      required super.serverFunctionsData,
      required this.client,
      required this.sftp,
      required this.notifications});

  String _decodeOutput(Uint8List output) {
    return utf8.decode(output);
  }

  Future<BasicDetails> get basicDetails async {
    try {
      String command = CommandBuilder().andAll(Commands.basicDetailsGroup);
      //TODO need to handle the condition of connection termination while running command
      if (client != null) {
        final basicDetails = _decodeOutput(await client!.run(command));
        return BasicDetails(BasicDetails.mapSource(basicDetails));
      }
      return BasicDetails({});
    } catch (_) {
      return BasicDetails({});
    }
  }

  Future<List<FileOrDirectory>?>? listRemoteDirectory(
      UploadCatogories catogory, String? insidPath,
      {bool empty = false, String customPath = ""}) async {
    List<FileOrDirectory> direcories = [];
    if (empty) {
      return direcories;
    } else {
      try {
        String? directory = super.folderConfiguration.pathToDirectory(catogory);
        if (catogory == UploadCatogories.custom && customPath.isNotEmpty) {
          directory = customPath;
        }
        if (directory != null && sftp != null) {
          if (insidPath != null) {
            directory = "$directory/$insidPath";
          }
          final items = await sftp!.listdir(directory);
          for (final item in items) {
            if (item.attr.isDirectory &&
                (item.filename != "." && item.filename != "..")) {
              String filepath =
                  "$directory/${FileManager.linuxCompatibleNameString(item.filename)}";
              direcories.add(DirectoryObject(
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
        return direcories;
      } catch (_) {
        return null;
      }
    }
  }

  Future<List<FileOrDirectory>?>? listAllRemoteDirectories(
      {required String path}) async {
    List<FileOrDirectory> direcories = [];
    try {
      List<dynamic> pathsToList = [];
      if (path.isNotEmpty) {
        pathsToList.add(path);
      } else {
        if (super.folderConfiguration.dataAvailable) {
          pathsToList.addAll([
            super.folderConfiguration.books,
            super.folderConfiguration.movies,
            super.folderConfiguration.tv
          ]);
        } else {
          return direcories;
        }
        if (super.folderConfiguration.customFolders.isNotEmpty) {
          pathsToList.addAll(super.folderConfiguration.customFolders);
        }
      }
      if (sftp != null) {
        for (var path in pathsToList) {
          await sftp!.listdir(path).then((items) {
            for (final item in items) {
              if (item.filename != "." && item.filename != "..") {
                String filepath =
                    "$path/${FileManager.linuxCompatibleNameString(item.filename)}";
                if (item.attr.isDirectory) {
                  direcories.add(DirectoryObject(
                      Directory(filepath),
                      item.filename,
                      item.attr.size ?? 0,
                      FileType.directory,
                      0, //intentionally put to zero because it does'nt matter at the moment
                      path,
                      filepath,
                      true,
                      FileCategory.getCategoryFromExtention(
                          item.filename.split(".").last),
                      item.attr.modifyTime ?? 0));
                } else {
                  direcories.add(FileObject(
                      File(filepath),
                      item.filename,
                      item.attr.size ?? 0,
                      item.filename.split(".").last,
                      path,
                      FileType.file,
                      filepath,
                      true,
                      FileCategory.getCategoryFromExtention(
                          item.filename.split(".").last),
                      item.attr.modifyTime ?? 0));
                }
              }
            }
          });
        }
        return direcories.toSet().toList(); //to remove duplicates
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  void loopAndSend(
      {required List<String> filePaths, required String directory}) {
    for (String filePath in filePaths) {
      sendFile(directory: directory, filePath: filePath);
    }
  }

  Future<void> sendFile(
      {required String directory, required String filePath}) async {
    try {
      if (sftp != null) {
        final int totalFileSize = File(filePath).lengthSync();
        final String fileName = filePath.split('/').last.toString();
        final String remotePath = "$directory/$fileName";
        final remoteFile = await sftp!.open(remotePath,
            mode: SftpFileOpenMode.create | SftpFileOpenMode.write);
        await remoteFile.write(
          File(filePath).openRead().cast(),
          onProgress: (progress) => notify(
              fileName: fileName,
              location: directory,
              fileSize: totalFileSize,
              progress: progress,
              notificationType: NotificationType.upload),
        );
      } else {
        notifications!.uploadError(error: AppMessages.serverNotAvailable);
      }
    } catch (_) {
      notifications!.uploadError(error: _.toString());
    }
  }

  Future<void> notify(
      {required String fileName,
      required String location,
      required int fileSize,
      required int progress,
      required NotificationType notificationType}) async {
    await notifications!.uploadNotification(
        id: fileName.hashCode.toString(),
        name: fileName,
        location: location,
        progress: progress,
        fileSize: fileSize,
        notificationType: notificationType);
  }

  Future<String> _createFolders(
      {required String directory, required List<String> newFolders}) async {
    try {
      for (String folder in newFolders) {
        directory += "/$folder";
        await sftp!.mkdir(directory);
      }
      return directory;
    } catch (_) {
      notifications!.uploadError(error: AppMessages.folderCreationError);
      return AppMessages.folderCreationError;
    }
  }

  Future<void> upload(
      {List<String> newFolders = const [],
      String insidPath = "",
      required String directory,
      required List<String> filePaths}) async {
    if (filePaths.isNotEmpty) {
      if (insidPath.isNotEmpty) {
        directory = "$directory/$insidPath";
      }
      if (newFolders.isEmpty) {
        loopAndSend(filePaths: filePaths, directory: directory);
      } else {
        await _createFolders(directory: directory, newFolders: newFolders)
            .then((createdDirectoryPath) {
          loopAndSend(filePaths: filePaths, directory: createdDirectoryPath);
        });
      }
    } else {
      notifications!.uploadError(error: AppMessages.filesNotSelected);
    }
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
      //this is implemented because for avoid delete errror `SftpStatusError`
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
    String newPath =
        "${fileOrDirectory.location}/${FileManager.linuxCompatibleNameString(newName)}";
    try {
      await sftp!.rename(fileOrDirectory.fullPath, newPath);
    } catch (_) {
      //this is implemented because for avoid delete errror `SftpStatusError`
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

  Future<void> download({required FileOrDirectory fileOrDirectory}) async {
    try {
      final remoteFile = await sftp!.open(fileOrDirectory.fullPath);
      File localFileObj =
          File("${FileManager.downloadLocation}/${fileOrDirectory.name}");
      final size = (await remoteFile.stat()).size;
      const defaultChunkSize = 1024 * 1024 * 10;
      if (size != null) {
        int chunkSize = size > defaultChunkSize ? defaultChunkSize : size;
        for (var i = chunkSize; chunkSize > 0; i += chunkSize) {
          final fileData = await remoteFile.readBytes(length: chunkSize);
          await localFileObj.writeAsBytes(fileData, mode: FileMode.append);
          notify(
              fileName: fileOrDirectory.name,
              location: FileManager.downloadLocation,
              fileSize: size,
              progress: i,
              notificationType: NotificationType.download);
          if (i + chunkSize > size) {
            chunkSize = size - i;
          }
        }
      }
    } catch (_) {}
  }
}
