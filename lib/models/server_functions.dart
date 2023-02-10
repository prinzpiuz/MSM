class ServerFunctionsData {
  bool wakeOnLan = false;
  bool autoUpdate = false;

  ServerFunctionsData();

  ServerFunctionsData.fromJson(Map<String, dynamic> json)
      : wakeOnLan = json['wakeOnLan'],
        autoUpdate = json['autoUpdate'];

  Map<String, bool> toJson() =>
      {'wakeOnLan': wakeOnLan, 'autoUpdate': autoUpdate};
}
