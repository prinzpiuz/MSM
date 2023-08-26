// Package imports:
import 'package:dartssh2/dartssh2.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/models/commands/commands.dart';

class Services {
  String unit = "";
  String serviceStatus = "";
  String description = "";
  late SSHClient client;

  bool get isActive {
    if (serviceStatus == "running") {
      return true;
    }
    return false;
  }

  Services(
      {required this.unit,
      required this.serviceStatus,
      required this.description});

  String get serviceName => unit.split(".").first;

  Future<bool> get start async {
    try {
      String command =
          CommandBuilder().addArguments(Commands.serviceStart, [unit]);
      await client.run(command);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> get stop async {
    try {
      String command =
          CommandBuilder().addArguments(Commands.serviceStop, [unit]);
      await client.run(command);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> get restart async {
    try {
      String command =
          CommandBuilder().addArguments(Commands.serviceRestart, [unit]);
      await client.run(command);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String> get status async {
    try {
      String command =
          CommandBuilder().addArguments(Commands.serviceStatus, [unit]);
      return decodeOutput(await client.run(command));
    } catch (_) {
      return _.toString();
    }
  }
}
