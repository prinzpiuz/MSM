// Package imports:
import 'dart:io' show File;

import 'package:dartssh2/dartssh2.dart';

// Project imports:
import 'package:msm/constants/constants.dart';
import 'package:msm/utils/commands/commands.dart' show Commands;
import 'package:msm/utils/folder_configuration.dart';
import 'package:msm/utils/server_details.dart';
import 'package:msm/utils/server_functions.dart';

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
      final username = serverData.username.trim();
      final host = serverData.serverHost.trim();
      final socket = await SSHSocket.connect(
        host,
        int.tryParse(serverData.portNumber) ?? 22,
        timeout: const Duration(seconds: 5),
      );

      SSHClient client;
      if (serverData.cachedPrivateKey != null) {
        client = SSHClient(
          socket,
          username: username,
          identities: serverData.cachedPrivateKey,
        );
      } else {
        if (serverData.privateKeyPath.isNotEmpty) {
          final privateKeyFile = File(serverData.privateKeyPath);
          final privateKeyContent = await privateKeyFile.readAsString();
          serverData.cachedPrivateKey = SSHKeyPair.fromPem(privateKeyContent);
          final identities = SSHKeyPair.fromPem(privateKeyContent);

          client = SSHClient(
            socket,
            username: username,
            identities: identities,
          );
        } else {
          client = SSHClient(
            socket,
            username: username,
            onPasswordRequest: () => serverData.rootPassword,
          );
        }
      }

      _client = client;
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
      _client = null;
      state = ServerState.disconnected;
    }
  }
}

Future<void> uploadPublicKey({
  required String host,
  required int port,
  required String username,
  required String password,
  required String publicKey,
}) async {
  final socket = await SSHSocket.connect(host, port);
  final client = SSHClient(
    socket,
    username: username,
    onPasswordRequest: () => password,
  );

  final session = await client.execute(Commands.copySSHKey(publicKey));

  await session.done;
  client.close();
}
