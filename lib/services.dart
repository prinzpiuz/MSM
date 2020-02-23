import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:msm/models.dart';
import 'dart:convert';



Future<TvFolders> fetchTvFolders() async {
  final response = await http.get('http://192.168.2.154/tv/folders');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    return TvFolders.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response, then throw an exception.
    throw Exception('Failed to load album');
  }
}

