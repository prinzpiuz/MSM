import 'dart:convert';

import 'package:filesize/filesize.dart';

// Project imports:
import 'package:msm/constants/constants.dart';

class Disk {
  final String source;
  String size = "";
  String used = "";
  String available = "";
  String usePercentage = "0";

  Disk(this.source) {
    if (source.isNotEmpty) {
      size = _parseSource(source)[0];
      used = _parseSource(source)[1];
      available = _parseSource(source)[2];
      usePercentage = _parseSource(source)[3];
    }
  }

  static List<String> _parseSource(String source) {
    List<String> splitSource = source.split(" ");
    List<String> output = [];
    for (String val in splitSource) {
      if (val.isNotEmpty && (val.contains("G") || val.contains("%"))) {
        output.add(val);
      }
    }
    return output;
  }

  double get percentage =>
      double.parse(usePercentage.replaceAll("%", '')) / 100;
}

class Ram {
  final String source;
  String size = "";
  String used = "";
  String free = "";

  Ram(this.source) {
    if (source.isNotEmpty) {
      size = _parseSource(source)[0];
      used = _parseSource(source)[1];
      free = _parseSource(source)[2];
    }
  }

  static List<String> _parseSource(String source) {
    List<String> splitSource = source.split(" ");
    List<String> output = [];
    for (String val in splitSource) {
      if (val.isNotEmpty) {
        output.add(val.replaceAll("i", ""));
      }
    }
    return output;
  }
}

class BasicDetails {
  Map<String, List<String>> source;
  String user = "";
  String uptime = "";
  String tempreture = "";
  late Ram ram;
  late Disk disk;

  BasicDetails(this.source) {
    if (source.isNotEmpty) {
      user = _parseUser(source);
      uptime = _parseUptime(source);
      tempreture = _parseTemperature(source);
      disk = _parseDisk(source);
      ram = _parseRam(source);
    }
  }

  static Map<String, List<String>> mapSource(String source) {
    Map<String, List<String>> outAsMap = {};
    for (var item in source.split("\n")) {
      if (item.isNotEmpty) {
        outAsMap.addAll({item.split(":")[0]: item.split(":").sublist(1)});
      }
    }
    return outAsMap;
  }

  static String _parseUser(Map<String, List<String>> source) {
    List<String> userSource = source[Identifiers.username]!;
    return userSource.first;
  }

  static Disk _parseDisk(Map<String, List<String>> source) {
    List<String> diskSource = source[Identifiers.disk]!;
    return Disk(diskSource.first);
  }

  static Ram _parseRam(Map<String, List<String>> source) {
    List<String> ramSource = source[Identifiers.ram]!;
    return Ram(ramSource.last);
  }

  static String _parseUptime(Map<String, List<String>> source) {
    List<String> uptimeSource = source[Identifiers.uptime]!;
    List<String> uptime = uptimeSource[0].split(" ");
    return "${uptime[1]} ${uptime[2].replaceAll(",", "")}";
  }

  static String _parseTemperature(Map<String, List<String>> source) {
    List<String> tempSource = source[Identifiers.temperature]!;
    return tempSource.first.split(" ").last;
  }
}

class Speed {
  String commandOutput = "";
  String upload = "";
  String download = "";
  String country = "";
  String isp = "";
  String ping = "";

  Speed({required this.commandOutput}) {
    if (commandOutput.isNotEmpty) {
      Map jsonData = jsonDecode(commandOutput);
      upload = jsonData["upload"].toString().split(".").first;
      download = jsonData["download"].toString().split(".").first;
      ping = jsonData["ping"].toString();
      country = jsonData["client"]["country"].toString();
      isp = jsonData["client"]["isp"].toString();
    }
  }

  String get uploadSpeed => "${filesize(upload)}/S";
  String get downloadSpeed => "${filesize(download)}/S";
}
