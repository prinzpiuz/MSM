import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssh/ssh.dart';

class BasicServerDetails {
  Future<Map<String, dynamic>> basicDetails() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> details;
    String hostname = "";
    String used = "";
    String total = "";
    String ip = prefs.getString('ip') ?? "";
    String username = prefs.getString('username') ?? "";
    String password = prefs.getString('password') ?? "";
    String port = prefs.getString('port') ?? "";
    String tvPath = prefs.getString('tvPath') ?? "";
    String moviePath = prefs.getString('moviePath') ?? "";
    try {
      if (ip != "") {
        var client = SSHClient(
          host: ip,
          port: int.parse(port),
          username: username,
          passwordOrKey: password,
        );
        var connect = await client.connect();
        if (connect == "session_connected") {
          hostname = await client.execute("hostname");
          used = await client.execute("du -sh ~/ | awk -F ' ' '{print \$1}'");
          total = await client.execute(
              "df -h /dev/sda2 | awk -F ' ' '{print \$2}' | awk -F 'Size' '{print \$1}'");
        }
        details = {
          "hostname": hostname,
          "client": client,
          "ip": ip,
          "username": username,
          "port": port,
          "password": password,
          "tvPath": tvPath,
          "moviePath": moviePath,
          "usedSpace": used,
          "totalSize": total
        };
      }
    } on Exception catch (e) {
      print(e);
    }
    return details;
  }
}
