// Dart imports:
import 'dart:io';

class ServerData {
  String serverName;
  String serverHost;
  String rootPassword;
  String portNumber;
  String macAddress;

  ServerData(
      {this.serverName = "",
      this.serverHost = "",
      this.rootPassword = "",
      this.portNumber = "22",
      this.macAddress = ""});

  InternetAddress get host => InternetAddress(serverHost);

  ServerData.fromJson(Map<String, dynamic> json)
      : serverName = json['serverName'],
        serverHost = json['serverHost'],
        rootPassword = json['rootPassword'],
        portNumber = json['portNumber'],
        macAddress = json['macAddress'];

  Map<String, dynamic> toJson() => {
        'serverName': serverName,
        'serverHost': serverHost,
        'rootPassword': rootPassword,
        'portNumber': portNumber,
        'macAddress': macAddress,
      };
}
