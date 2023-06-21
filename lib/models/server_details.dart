// Dart imports:
import 'dart:io';

class ServerData {
  String serverName;
  String serverHost;
  String username;
  String rootPassword;
  String portNumber;
  String macAddress;

  ServerData(
      {this.serverName = "",
      this.serverHost = "",
      this.username = "",
      this.rootPassword = "",
      this.portNumber = "22",
      this.macAddress = ""});

  int get port => int.parse(portNumber);

  bool get detailsAvailable {
    if (serverHost.isNotEmpty &&
        username.isNotEmpty &&
        rootPassword.isNotEmpty &&
        portNumber.isNotEmpty) {
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
        macAddress = json['macAddress'];

  Map<String, dynamic> toJson() => {
        'serverName': serverName,
        'serverHost': serverHost,
        'username': username,
        'rootPassword': rootPassword,
        'portNumber': portNumber,
        'macAddress': macAddress,
      };
}
