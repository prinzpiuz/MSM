import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:msm/models.dart';
import 'dart:convert';
import 'package:ssh/ssh.dart';

Future<TvFolders> fetchTvFolders(basicDeatials) async {
  final sshClient = basicDeatials["client"];
  var array;
  // final prefs = await SharedPreferences.getInstance();
  // String text = prefs.getString('ip') ?? "";
  try {
    String result = await sshClient.connect();
    if (result == "session_connected") {
      result = await sshClient.connectSFTP();
      if (result == "sftp_connected") {
         array = await sshClient.sftpLs(basicDeatials["tvPath"]);
      }
    }
  } on Exception catch (e) {
    print(e);
  }
  List<String> folderList = [];
  array.map((f) {
    folderList.add(f["filename"]);
    // "${f["filename"]} ${f["isDirectory"]} ${f["modificationDate"]} ${f["lastAccess"]} ${f["fileSize"]} ${f["ownerUserID"]} ${f["ownerGroupID"]} ${f["permissions"]} ${f["flags"]}";
  });
  print("array $folderList");
  print("arraylength $array");
  // if (_array.length > 0) {
  //   // final response = await http.get('http://' + text + '/tv/folders');

  //   if (response.statusCode == 200) {
  //     // If the server did return a 200 OK response, then parse the JSON.
  //     return TvFolders.fromJson(json.decode(response.body));
  //   } else {
  //     // If the server did not return a 200 OK response, then throw an exception.
  //     throw Exception('Failed to load folders');
  //   }
  // } else {
  //   throw Exception('ip not configured');
  // }
  // return array;
  return TvFolders.fromJson({"folders": folderList});
}
