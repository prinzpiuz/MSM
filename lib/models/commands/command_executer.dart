// Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// Package imports:
import 'package:dartssh2/dartssh2.dart';

// Project imports:
import 'package:msm/models/commands/basic_details.dart';
import 'package:msm/models/commands/commands.dart';
import 'package:msm/models/file_manager.dart';
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
      {bool empty = false}) async {
    List<FileOrDirectory> direcories = [];
    if (empty) {
      return direcories;
    } else {
      try {
        String? directory = super.folderConfiguration.pathToDirectory(catogory);
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
      required SftpClient sftp}) async {
    for (String filePath in filePaths) {
      await _sendFile(directory: directory, filePath: filePath, sftp: sftp);
    }
  }

  Future<void> _sendFile(
      {required String directory,
      required String filePath,
      required SftpClient sftp}) async {
    try {
      final String remotePath =
          "$directory/${filePath.split('/').last.toString()}";
      final remoteFile = await sftp.open(remotePath,
          mode: SftpFileOpenMode.create | SftpFileOpenMode.write);
      await remoteFile.write(
        File(filePath).openRead().cast(),
        onProgress: (total) => print(total),
      );
    } catch (_) {}
  }

  Future<String> _createFolders(
      {required SftpClient sftp,
      required String directory,
      required List<String> newFolders}) async {
    try {
      for (String folder in newFolders) {
        directory += "/$folder";
        await sftp.mkdir(directory);
      }
      return directory;
    } catch (_) {
      return "Error Occured While Creating Folders";
    }
  }

  Future<void> upload(
      {List<String> newFolders = const [],
      String insidPath = "",
      required String directory,
      required List<String> filePaths}) async {
    try {
      if (client != null && filePaths.isNotEmpty) {
        await client!.sftp().then((value) async {
          if (insidPath.isNotEmpty) {
            directory = "$directory/$insidPath";
          }
          final sftp = value;
          if (newFolders.isEmpty) {
            await loopAndSend(
                filePaths: filePaths, directory: directory, sftp: sftp);
          } else {
            await _createFolders(
                    sftp: sftp, directory: directory, newFolders: newFolders)
                .then((createdDirectoryPath) async {
              await loopAndSend(
                  filePaths: filePaths,
                  directory: createdDirectoryPath,
                  sftp: sftp);
            });
          }
        });
      }
    } catch (_) {}
  }
}
