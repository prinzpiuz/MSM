// Package imports:
import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';

// Project imports:
import 'package:msm/models/folder_configuration.dart';
import 'package:msm/models/server_details.dart';
import 'package:msm/models/server_functions.dart';

class Server {
  ServerData serverData;
  FolderConfiguration? folderConfiguration;
  ServerFunctionsData? serverFunctionsData;
  SSHClient? _client;

  Server(
      {required this.serverData,
      required this.folderConfiguration,
      required this.serverFunctionsData});

  Future<SSHClient?> connect() async {
    _client = SSHClient(
      await SSHSocket.connect(serverData.serverHost, serverData.port),
      username: serverData.username,
      onPasswordRequest: () => serverData.rootPassword,
    );
    return _client;
  }
}

class BasicDetails extends Server {
  String _user = "";
  String usedSpace = "";
  String totalSpace = "";
  String uptime = "";
  String tempreture = "";

  BasicDetails({required super.serverData})
      : super(folderConfiguration: null, serverFunctionsData: null);

  Future<dynamic> get getUser async {
    SSHClient? client = await super.connect();
    if (client != null) {
      print("here");
      final commandToExecute = await client.run('whoami');
      print(utf8.decode(commandToExecute));
      _user = utf8.decode(commandToExecute);
      print(commandToExecute);
      return _user;
    }
    return "Not found";
  }
}
