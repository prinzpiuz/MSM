class ServerFunctionsData {
  bool wakeOnLan = false;
  bool autoUpdate = false;
  bool sendTokindle = false;

  ServerFunctionsData();

  ServerFunctionsData.fromJson(Map<String, dynamic> json)
      : wakeOnLan = json['wakeOnLan'],
        autoUpdate = json['autoUpdate'],
        sendTokindle = json['sendTokindle'];

  Map<String, bool> toJson() => {
        'wakeOnLan': wakeOnLan,
        'autoUpdate': autoUpdate,
        'sendTokindle': sendTokindle
      };
}
