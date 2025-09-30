// Dart imports:
import 'dart:io';

import 'package:dartssh2/dartssh2.dart' show SSHKeyPair;

class ServerData {
  String serverName;
  String serverHost;
  String username;
  String rootPassword;
  String portNumber;
  String macAddress;
  String privateKeyPath;
  List<SSHKeyPair>? cachedPrivateKey;

  ServerData(
      {this.serverName = "",
      this.serverHost = "",
      this.username = "",
      this.rootPassword = "",
      this.portNumber = "22",
      this.macAddress = "",
      this.privateKeyPath = ""});

  int get port => int.parse(portNumber);

  bool get detailsAvailable {
    if (serverHost.isNotEmpty &&
        username.isNotEmpty &&
        (rootPassword.isNotEmpty || privateKeyPath.isNotEmpty) &&
        portNumber.isNotEmpty) {
      return true;
    }
    return false;
  }

  bool get detailsForKeyUploadAvailable {
    if (serverHost.isNotEmpty && username.isNotEmpty && portNumber.isNotEmpty) {
      return true;
    }
    return false;
  }

  InternetAddress get host => InternetAddress(serverHost);

  ServerData.fromJson(Map<String, dynamic> json)
      : serverName = json['serverName'],
        serverHost = json['serverHost'],
        username = json['username'],
        rootPassword = json['rootPassword'],
        portNumber = json['portNumber'],
        macAddress = json['macAddress'],
        privateKeyPath = json['privateKeyPath'];

  Map<String, dynamic> toJson() => {
        'serverName': serverName,
        'serverHost': serverHost,
        'username': username,
        'rootPassword': rootPassword,
        'portNumber': portNumber,
        'macAddress': macAddress,
        'privateKeyPath': privateKeyPath
      };
}
