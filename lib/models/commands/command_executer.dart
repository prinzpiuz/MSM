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
    String command = CommandBuilder().andAll(Commands.basicDetailsGroup);
    //TODO need to handle the condition of connection termination while running command
    if (client != null) {
      final basicDetails = _decodeOutput(await client!.run(command));
      return BasicDetails(BasicDetails.mapSource(basicDetails));
    }
    return BasicDetails({});
  }

  Future<List<FileOrDirectory>>? listRemoteDirectory(
      UploadCatogories catogories) async {
    List<FileOrDirectory> direcories = [];
    final directory = super.folderConfiguration.pathToDirectory(catogories);
    if (directory != null && client != null) {
      final sftp = await client!.sftp();
      final items = await sftp.listdir(directory);
      for (final item in items) {
        if (item.attr.isDirectory &&
            (item.filename != "." || item.filename != "..")) {
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
  }
}
