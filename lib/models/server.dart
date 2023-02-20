import 'package:dartssh2/dartssh2.dart';
import 'package:msm/models/folder_configuration.dart';
import 'package:msm/models/server_details.dart';
import 'package:msm/models/server_functions.dart';

class Server {
  ServerData serverData;
  FolderConfiguration folderConfiguration;
  ServerFunctionsData serverFunctionsData;
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

  Future<SSHClient?> get client async => await connect();
}
