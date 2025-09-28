// Project imports:
import 'package:msm/constants/constants.dart';

class Commands {
  //added echo -n '<identifier>:' to prepend and identifier with the command output
  static const whoAmI = "whoami";
  static const uptime = "uptime -p";
  static const linuxDistribution = "lsb_release -i -s";
  // https://askubuntu.com/a/854029/596101
  static const temperature =
      r"paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/' | grep x86_pkg_temp";
  // --exclude-type=overlay to avoid showing overlay filesystems
  static const diskUsage =
      "df -hl --total --exclude-type=overlay | awk 'END{print}'";
  static const ramUsage = "free -h | grep Mem";
  static const deleteFileOrFolders = "rm -rf";
  static const rename = "mv";
  static const base64 = "base64 --wrap=0";
  // added `end` at the end for identification it also used for splitting output string
  static const getServices =
      r"""systemctl --type=service -a --plain | awk '{ print $1,"," $3,"," $4,",", $5,$6,$7,$8,$9,"end"}'""";
  static const serviceStart = "systemctl start";
  static const serviceStatus = "systemctl status";
  static const serviceStop = "systemctl stop";
  static const serviceRestart = "systemctl restart";
  static const ping = "";
  static const speedTest = "speedtest-cli --secure --bytes --json";
  static String folderExist(String folder) =>
      "if [ -d \"$folder\" ]; then echo 'Exists'; else echo 'Not found'; fi";

  static List<String> basicDetailsGroup = [
    addIdentifier(whoAmI, Identifiers.username),
    addIdentifier(uptime, Identifiers.uptime),
    addIdentifier(temperature, Identifiers.temperature),
    addIdentifier(diskUsage, Identifiers.disk),
    addIdentifier(ramUsage, Identifiers.ram)
  ];

  static String addIdentifier(String command, String identifier) {
    return "echo -n '$identifier:';$command";
  }

  static String copySSHKey(String publicKey) {
    return '''
    mkdir -p ~/.ssh && chmod 700 ~/.ssh &&
    echo "$publicKey" >> ~/.ssh/authorized_keys &&
    chmod 600 ~/.ssh/authorized_keys
  ''';
  }

  Commands._();
}

class Operators {
  static const and = "&&";
  static const grep = "|";
}

class CommandBuilder {
  String output = "";

  String andAll(List<String> commands) {
    // put && inbetween the commands in list
    if (commands.length == 1) {
      return commands.first;
    } else {
      for (int i = 0; i < commands.length; i++) {
        output += "${i == 0 ? '' : Operators.and} ${commands[i]} ";
      }
      return output;
    }
  }

  String grepAll(List<String> commands) {
    // put | inbetween the commands in list
    if (commands.length == 1) {
      return commands.first;
    } else {
      for (int i = 0; i < commands.length; i++) {
        output += "${i == 0 ? '' : Operators.grep} ${commands[i]} ";
      }
      return output;
    }
  }

  String addArguments(String command, List<String> args) {
    //add arguments to command supplied
    if (args.length == 1) {
      return "$command ${args.first}";
    } else {
      for (int i = 0; i < args.length; i++) {
        output += "${i == 0 ? command : ''} ${args[i]} ";
      }
      return output;
    }
  }
}
