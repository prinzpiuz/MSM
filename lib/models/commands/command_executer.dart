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
import 'package:msm/models/file_upload.dart';
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

  void loopAndSend(
      {required List<FileOrDirectory> uploadData,
      required String directory,
      required SftpClient sftp}) {
    for (FileOrDirectory file in uploadData) {
      _sendFile(directory: directory, file: file, sftp: sftp);
    }
  }

  void _sendFile(
      {required String directory,
      required FileOrDirectory file,
      required SftpClient sftp}) async {
    final String remotePath = "$directory/${file.name}";
    final remoteFile = await sftp.open(remotePath,
        mode: SftpFileOpenMode.create | SftpFileOpenMode.write);
    final localPath = file.fullPath;
    await remoteFile.write(
      File(localPath).openRead().cast(),
      onProgress: (total) => print(total),
    );
  }

  Future<String> _createFolders(
      {required SftpClient sftp,
      required String directory,
      required List<String> newFolders}) async {
    for (String folder in newFolders) {
      directory += "/$folder";
      await sftp.mkdir(directory);
    }
    return directory;
  }

  Future<bool> upload(
      {List<String> newFolders = const [],
      String insidPath = "",
      required UploadCatogories category,
      required FileUploadData fileUploadData}) async {
    try {
      String? directory = super.folderConfiguration.pathToDirectory(category);
      if (insidPath.isNotEmpty) {
        directory = "$directory/$insidPath";
      }
      if (client != null &&
          directory != null &&
          fileUploadData.uploadData.isNotEmpty) {
        final sftp = await client!.sftp();
        if (newFolders.isEmpty) {
          loopAndSend(
              uploadData: fileUploadData.uploadData,
              directory: directory,
              sftp: sftp);
        } else {
          await _createFolders(
                  sftp: sftp, directory: directory, newFolders: newFolders)
              .then((createdDirectoryPath) => {
                    loopAndSend(
                        uploadData: fileUploadData.uploadData,
                        directory: createdDirectoryPath,
                        sftp: sftp)
                  });
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
