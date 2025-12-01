/// A collection of predefined shell commands for system management operations.
/// All commands are designed to be executed on Linux systems.
class Commands {
  // File and folder operations
  /// Deletes files or folders recursively and forcefully.
  static const deleteFileOrFolders = "rm -rf";

  /// Renames or moves files/folders.
  static const rename = "mv";

  /// Encodes data to base64 without line wrapping.
  static const base64 = "base64 --wrap=0";

  // Service management commands
  /// Lists all services with status information, formatted with commas and 'end' marker.
  static const String getServices =
      "systemctl --type=service -a --plain | awk '{ print \$1, \",\" , \$3, \",\" , \$4, \",\" , \$5\$6\$7\$8\$9,\"end\"}'";

  /// Starts a systemd service.
  static const serviceStart = "systemctl start";

  /// Gets the status of a systemd service.
  static const serviceStatus = "systemctl status";

  /// Stops a systemd service.
  static const serviceStop = "systemctl stop";

  /// Restarts a systemd service.
  static const serviceRestart = "systemctl restart";

  // Network commands
  /// Placeholder for ping command (currently empty - set as needed).
  static const ping = "";

  /// Runs speed test and outputs JSON results.
  static const speedTest = "speedtest-cli --secure --bytes --json";

  /// Checks if a folder exists on the filesystem.
  /// Properly escapes the folder path to handle special characters.
  static String folderExist(String folder) {
    final escapedFolder = folder.replaceAll("'", "\\'");
    return "if [ -d '$escapedFolder' ]; then echo 'Exists'; else echo 'Not found'; fi";
  }

  /// Prepends an identifier to a command output for easy parsing.
  static String addIdentifier(String command, String identifier) {
    return "echo -n '$identifier:';$command";
  }

  /// Generates a command to copy an SSH public key to authorized_keys.
  /// Properly escapes the public key to handle special characters.
  static String copySSHKey(String publicKey) {
    final escapedKey = publicKey.replaceAll("'", "\\'");
    return '''
mkdir -p ~/.ssh && chmod 700 ~/.ssh &&
echo '$escapedKey' >> ~/.ssh/authorized_keys &&
chmod 600 ~/.ssh/authorized_keys
''';
  }

  Commands._();
}

/// Shell command operators for chaining commands.
class Operators {
  /// Logical AND operator.
  static const and = "&&";

  /// Pipe operator for command chaining.
  static const pipe = "|";
}

/// Utility class for building complex shell commands from simpler parts.
/// All methods are pure functions to ensure immutability and thread safety.
class CommandBuilder {
  /// Combines a list of commands with the AND operator (&&).
  /// Returns the single command if the list has only one element.
  static String andAll(List<String> commands) {
    if (commands.isEmpty) return '';
    if (commands.length == 1) return commands.first;
    return commands.join(' ${Operators.and} ');
  }

  /// Combines a list of commands with the pipe operator (|).
  /// Returns the single command if the list has only one element.
  static String pipeAll(List<String> commands) {
    if (commands.isEmpty) return '';
    if (commands.length == 1) return commands.first;
    return commands.join(' ${Operators.pipe} ');
  }

  /// Adds arguments to a base command.
  /// Returns the command with arguments appended.
  static String addArguments(String command, List<String> args) {
    if (args.isEmpty) return command;
    final escapedArgs = args.map((arg) => arg.replaceAll("'", "\\'")).join(' ');
    return '$command $escapedArgs';
  }
}
