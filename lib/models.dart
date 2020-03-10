import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssh/ssh.dart';

class BasicServerDetails {
  Future<Map<String, dynamic>> basicDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString('ip') ?? "";
    String username = prefs.getString('username') ?? "";
    String password = prefs.getString('password') ?? "";
    String port = prefs.getString('port') ?? "";
    String tvPath = prefs.getString('tvPath') ?? "";
    String moviePath = prefs.getString('moviePath') ?? "";
    var client = SSHClient(
      host: ip,
      port: int.parse(port),
      username: username,
      passwordOrKey: password,
    );
    var connect = await client.connect();
    // print("connect $connect");
    var hostname = await client.execute("hostname");
    var used = await client.execute("du -sh ~/ | awk -F ' ' '{print \$1}'");
    var total = await client.execute(
        "df -h /dev/sda2 | awk -F ' ' '{print \$2}' | awk -F 'Size' '{print \$1}'");
    return {
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
}
