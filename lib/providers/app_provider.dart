// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:msm/models/storage.dart';

class AppService with ChangeNotifier {
  //TODO add server class also here for having the connection status
  bool _connectionState = true;
  bool _initialized = false;
  bool _onboarding = false;

  AppService();

  bool get loginState => _connectionState;
  bool get initialized => _initialized;
  bool get onboarding => _onboarding;

  set connectionState(bool state) {
    _connectionState = state;
    notifyListeners();
  }

  set initialized(bool value) {
    _initialized = value;
    notifyListeners();
  }

  set onboarding(bool value) {
    Storage().setFirstTimeInstall(value);
    _onboarding = value;
    notifyListeners();
  }

  Future<void> onAppStart() async {
    _onboarding = await Storage().getFirstTimeInstall();
    _initialized = true;
    notifyListeners();
  }
}
