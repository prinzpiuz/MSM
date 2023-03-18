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
  CommandExecuter(
      {required super.serverData,
      required super.folderConfiguration,
      required super.serverFunctionsData,
      required this.client});

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
        if (directory != null && client != null) {
          if (insidPath != null) {
            directory = "$directory/$insidPath";
          }
          final sftp = await client!.sftp();
          final items = await sftp.listdir(directory);
          sftp.close();
          for (final item in items) {
            if (item.attr.isDirectory &&
                (item.filename != "." && item.filename != "..")) {
              direcories.add(DirectoryObject(
                  Directory("$directory/${item.filename}"),
                  item.filename,
                  FileType.directory,
                  0, //intentionally put to zero because it does'nt matter at the moment
                  directory));
            }
          }
        }
        return direcories;
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> loopAndSend(
      {required List<String> filePaths,
      required String directory,
      required SftpClient sftp,
      required Notifications notification}) async {
    for (String filePath in filePaths) {
      await _sendFile(
          directory: directory,
          filePath: filePath,
          sftp: sftp,
          notification: notification);
    }
  }

  Future<void> _sendFile(
      {required String directory,
      required String filePath,
      required SftpClient sftp,
      required Notifications notification}) async {
    try {
      final String fileName = filePath.split('/').last.toString();
      final String remotePath = "$directory/$fileName";
      final remoteFile = await sftp.open(remotePath,
          mode: SftpFileOpenMode.create | SftpFileOpenMode.write);
      await remoteFile.write(
        File(filePath).openRead().cast(),
        onProgress: (total) async {
          await notification.uploadNotification(
              id: fileName.hashCode.toString(),
              name: fileName,
              location: directory,
              progress: total,
              fileSize: File(filePath).lengthSync());
        },
      );
    } catch (_) {
      notification.uploadError(error: _.toString());
    }
  }

  Future<String> _createFolders(
      {required SftpClient sftp,
      required String directory,
      required List<String> newFolders,
      required Notifications notification}) async {
    try {
      for (String folder in newFolders) {
        directory += "/$folder";
        await sftp.mkdir(directory);
      }
      return directory;
    } catch (_) {
      notification.uploadError(error: AppMessages.folderCreationError);
      return AppMessages.folderCreationError;
    }
  }

  Future<void> upload(
      {List<String> newFolders = const [],
      String insidPath = "",
      required String directory,
      required List<String> filePaths}) async {
    final Notifications notifications = Notifications();
    try {
      if (client != null && filePaths.isNotEmpty) {
        await client!.sftp().then((value) async {
          if (insidPath.isNotEmpty) {
            directory = "$directory/$insidPath";
          }
          final sftp = value;
          if (newFolders.isEmpty) {
            await loopAndSend(
                filePaths: filePaths,
                directory: directory,
                sftp: sftp,
                notification: notifications);
          } else {
            await _createFolders(
                    sftp: sftp,
                    directory: directory,
                    newFolders: newFolders,
                    notification: notifications)
                .then((createdDirectoryPath) async {
              await loopAndSend(
                  filePaths: filePaths,
                  directory: createdDirectoryPath,
                  sftp: sftp,
                  notification: notifications);
            });
          }
        });
      } else {
        notifications.uploadError(
            error:
                client == null ? "Server Not Available" : "Files Not Selected");
      }
    } catch (_) {
      notifications.uploadError(error: _.toString());
    }
  }
}
