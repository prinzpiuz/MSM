import 'package:dartssh2/dartssh2.dart';
import 'package:msm/common_utils.dart';
import 'package:msm/models/commands/commands.dart';

class Services {
  String unit = "";
  String serviceStatus = "";
  String description = "";

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

  String serviceName() {
    return unit.split(".").last;
  }

  Future<String> start(SSHClient client) async {
    try {
      String command =
          CommandBuilder().addArguments(Commands.serviceStart, [unit]);
      return decodeOutput(await client.run(command));
    } catch (_) {
      return _.toString();
    }
  }

  Future<String> stop(SSHClient client) async {
    try {
      String command =
          CommandBuilder().addArguments(Commands.serviceStop, [unit]);
      return decodeOutput(await client.run(command));
    } catch (_) {
      return _.toString();
    }
  }

  Future<String> restart(SSHClient client) async {
    try {
      String command =
          CommandBuilder().addArguments(Commands.serviceRestart, [unit]);
      return decodeOutput(await client.run(command));
    } catch (_) {
      return _.toString();
    }
  }

  Future<String> status(SSHClient client) async {
    try {
      String command =
          CommandBuilder().addArguments(Commands.serviceStatus, [unit]);
      return decodeOutput(await client.run(command));
    } catch (_) {
      return _.toString();
    }
  }
}
