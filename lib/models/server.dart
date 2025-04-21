// Package imports:
import 'package:dartssh2/dartssh2.dart';

// Project imports:
import 'package:msm/constants/constants.dart';
import 'package:msm/models/folder_configuration.dart';
import 'package:msm/models/server_details.dart';
import 'package:msm/models/server_functions.dart';

enum ServerState {
  disconnected,
  connecting,
  connected,
  failed;

  bool get shouldConnect =>
      this == ServerState.disconnected || this == ServerState.failed;

  String get message {
    switch (this) {
      case ServerState.connected:
        return AppConstants.connected;
      case ServerState.disconnected:
        return AppConstants.disconnected;
      case ServerState.connecting:
        return AppConstants.connecting;
      case ServerState.failed:
        return AppConstants.notAvailable;
    }
  }
}

class Server {
  ServerData serverData;
  FolderConfiguration folderConfiguration;
  ServerFunctionsData serverFunctionsData;
  SSHClient? _client;
  ServerState state = ServerState.disconnected;

  Server(
      {required this.serverData,
      required this.folderConfiguration,
      required this.serverFunctionsData});

  Future<SSHClient?> connect() async {
    try {
      _client = SSHClient(
        await SSHSocket.connect(
          serverData.serverHost,
          serverData.port,
          timeout: const Duration(seconds: 5),
        ),
        username: serverData.username.trim(),
        onPasswordRequest: () => serverData.rootPassword,
      );
      state = ServerState.connected;
      return _client;
    } catch (_) {
      state = ServerState.failed;
      return null;
    }
  }

  void close() async {
    if (_client != null) {
      _client?.close();
      await _client?.done;
    }
  }
}
