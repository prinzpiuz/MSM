// Dart imports:
import 'dart:convert';
import 'dart:typed_data';

// Package imports:
import 'package:dartssh2/dartssh2.dart';

// Project imports:
import 'package:msm/models/commands/basic_details.dart';
import 'package:msm/models/commands/commands.dart';
import 'package:msm/models/server.dart';

class CommandExecuter extends Server {
  late SSHClient client;
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
    final basicDetails = _decodeOutput(await client.run(command));
    return BasicDetails(BasicDetails.mapSource(basicDetails));
  }
}
