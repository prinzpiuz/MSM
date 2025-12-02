// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:filesize/filesize.dart';

// Project imports:

class Disk {
  /// Total disk size (e.g., "500G")
  final String size;

  /// Used disk space (e.g., "200G")
  final String used;

  /// Available disk space (e.g., "300G")
  final String available;

  /// Usage percentage as string (e.g., "40%")
  final String usePercentage;

  /// Mount point (e.g., "/")
  final String mount;

  /// File system type (e.g., "ext4")
  final String fstype;

  /// Device name (e.g., "/dev/sda1")
  final String device;

  /// Transport type (e.g., "SATA")
  final String transport;

  /// Whether the disk is removable
  final bool removable;

  /// Creates a Disk instance with empty values.
  const Disk.empty()
      : size = '',
        used = '',
        available = '',
        usePercentage = '0%',
        mount = '',
        fstype = '',
        device = '',
        transport = '',
        removable = false;

  /// Creates a Disk instance by parsing JSON source data.
  ///
  /// Expected source format: JSON string with disk information.
  /// Handles missing keys and type conversion errors gracefully.
  factory Disk(Map<String, dynamic> data) {
    if (data.isEmpty) {
      return const Disk.empty();
    }

    try {
      return Disk._internal(
        size: _parseString(data, 'size'),
        used: _parseString(data, 'used'),
        available: _parseString(data, 'available'),
        usePercentage: _parseString(data, 'use_percentage'),
        mount: _parseString(data, 'mount'),
        fstype: _parseString(data, 'fstype'),
        device: _parseString(data, 'device'),
        transport: _parseString(data, 'transport'),
        removable: _parseBool(data, 'removable'),
      );
    } catch (e) {
      // Fallback to empty values on parsing error
      return const Disk.empty();
    }
  }

  const Disk._internal({
    required this.size,
    required this.used,
    required this.available,
    required this.usePercentage,
    required this.mount,
    required this.fstype,
    required this.device,
    required this.transport,
    required this.removable,
  });

  /// Safely parses a string value from the source map.
  static String _parseString(Map<String, dynamic> source, String key) {
    try {
      final value = source[key];
      return value?.toString() ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Safely parses a boolean value from the source map.
  static bool _parseBool(Map<String, dynamic> source, String key) {
    try {
      final value = source[key];
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      if (value is int) return value != 0;
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Returns usage percentage as a double (0.0 to 1.0).
  /// Handles invalid percentage strings gracefully.
  double get percentage {
    if (usePercentage.isEmpty) return 0.0;
    try {
      final cleaned = usePercentage.replaceAll('%', '').trim();
      final value = double.parse(cleaned);
      return (value / 100).clamp(0.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }

  /// Returns usage percentage as an integer (0 to 100).
  int get percentageInt => (percentage * 100).round();

  /// Returns usage percentage as a formatted string.
  String get percentageFormatted => '$percentageInt%';

  /// Checks if disk data is available (has non-empty size).
  bool get hasData => size.isNotEmpty;

  /// Converts a size string (e.g., "233G", "511M") into bytes.
  /// Assumes standard decimal or binary prefixes (1024 for M/G).
  ///
  /// Throws a FormatException if the string format is unexpected.
  int _parseSizeToBytes(String sizeString) {
    final regex = RegExp(r'^(\d+)([GM])$');
    final match = regex.firstMatch(sizeString.trim());

    if (match == null) {
      throw FormatException('Invalid size string format: $sizeString');
    }

    final value = int.parse(match.group(1)!);
    final unit = match.group(2)!;

    // Using 1024 for storage calculations (binary prefixes)
    const int mInBytes = 1024 * 1024;
    const int gInBytes = 1024 * mInBytes;

    switch (unit) {
      case 'M':
        return value * mInBytes;
      case 'G':
        return value * gInBytes;
      default:
        // Should be caught by regex, but for completeness
        return 0;
    }
  }

  int get sizeInBytes => _parseSizeToBytes(size);

  int get usedInBytes => _parseSizeToBytes(used);

  /// Returns a formatted string representation of disk usage.
  @override
  String toString() =>
      'Disk: $used / $size ($available free) at $mount ($percentageFormatted)';
}

class Ram {
  /// Total RAM size (e.g., "8.0G")
  final String size;

  /// Used RAM amount (e.g., "2.5G")
  final String used;

  /// Available (free) RAM amount (e.g., "5.5G")
  final String free;

  /// Creates a Ram instance with empty values.
  const Ram.empty()
      : size = '',
        used = '',
        free = '';

  /// Creates a Ram instance by parsing JSON source data.
  ///
  /// Expected source format: {"available":"free_value","used":"used_value","size":"total_value"}
  /// Handles missing keys and type conversion errors gracefully.
  factory Ram(Map<String, dynamic> data) {
    if (data.isEmpty) {
      return const Ram.empty();
    }

    try {
      return Ram._internal(
        size: _parseString(data, 'size'),
        used: _parseString(data, 'used'),
        free: _parseString(data, 'available'),
      );
    } catch (e) {
      // Fallback to empty values on parsing error
      return const Ram.empty();
    }
  }

  const Ram._internal({
    required this.size,
    required this.used,
    required this.free,
  });

  /// Safely parses a string value from the source map.
  static String _parseString(Map<String, dynamic> source, String key) {
    try {
      final value = source[key];
      return value?.toString() ?? '';
    } catch (e) {
      return '';
    }
  }

  double get ramUsageInBytes {
    return _parseSizeToBytes(used);
  }

  double get ramSizeInBytes {
    return _parseSizeToBytes(size);
  }

  /// Returns RAM usage percentage as a formatted string.
  String get usagePercentage {
    if (size.isEmpty || used.isEmpty) return '0%';
    try {
      final totalBytes = _parseSizeToBytes(size);
      final usedBytes = _parseSizeToBytes(used);
      if (totalBytes == 0) return '0%';
      final percentage = (usedBytes / totalBytes * 100).round();
      return '$percentage%';
    } catch (e) {
      return '0%';
    }
  }

  // / Converts human-readable size (e.g., "1.5G") to bytes for calculations.
  static double _parseSizeToBytes(String size) {
    if (size.isEmpty) return 0.0;
    try {
      final regex = RegExp(r'(\d+(?:\.\d+)?)\s*([KMGT]?)');
      final match = regex.firstMatch(size.toUpperCase());
      if (match == null) return 0.0;

      final value = double.parse(match.group(1)!);
      final unit = match.group(2) ?? '';

      const multipliers = {
        'K': 1024,
        'M': 1024 * 1024,
        'G': 1024 * 1024 * 1024,
        'T': 1024 * 1024 * 1024 * 1024
      };
      final multiplier = multipliers[unit] ?? 1;

      return value * multiplier;
    } catch (e) {
      return 0.0;
    }
  }

  /// Checks if RAM data is available (has non-empty size).
  bool get hasData => size.isNotEmpty;

  /// Returns a formatted string representation of RAM usage.
  @override
  String toString() => 'RAM: $used / $size ($free free)';
}

/// Represents CPU information parsed from system monitoring data.
///
/// This class provides structured access to CPU details including model, cores,
/// usage statistics, load averages, and frequency information.
class CPU {
  /// CPU model name (e.g., "Intel(R) Core(TM) i3-6006U CPU @ 2.00GHz")
  final String model;

  /// Number of CPU cores
  final int cores;

  /// Current CPU usage percentage (can be negative for some systems)
  final double usage;

  /// Load averages as a list of three values (1min, 5min, 15min)
  final List<double> load;

  /// BogoMIPS value as a string (system-dependent benchmark)
  final String bogomips;

  /// CPU frequency in MHz
  final double freqMhz;

  /// Creates a CPU instance with default empty values.
  const CPU.empty()
      : model = '',
        cores = 0,
        usage = 0.0,
        load = const [],
        bogomips = '',
        freqMhz = 0.0;

  /// Creates a CPU instance by parsing data from a source map.
  ///
  /// Expected source structure:
  /// {
  ///   'model': String,
  ///   'cores': int,
  ///   'usage': num,
  ///   'load': List[num],
  ///   'bogomips': String,
  ///   'freq_mhz': num
  /// }
  ///
  /// Handles missing keys and type conversion errors gracefully.
  factory CPU.fromSource(Map<String, dynamic> source) {
    return CPU._internal(
      model: _parseString(source, 'model'),
      cores: _parseInt(source, 'cores'),
      usage: _parseDouble(source, 'usage'),
      load: _parseLoadList(source, 'load'),
      bogomips: _parseString(source, 'bogomips'),
      freqMhz: _parseDouble(source, 'freq_mhz'),
    );
  }

  const CPU._internal({
    required this.model,
    required this.cores,
    required this.usage,
    required this.load,
    required this.bogomips,
    required this.freqMhz,
  });

  /// Safely parses a string value from the source map.
  static String _parseString(Map<String, dynamic> source, String key) {
    try {
      final value = source[key];
      return value?.toString() ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Safely parses an integer value from the source map.
  static int _parseInt(Map<String, dynamic> source, String key) {
    try {
      final value = source[key];
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is num) return value.toInt();
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Safely parses a double value from the source map.
  static double _parseDouble(Map<String, dynamic> source, String key) {
    try {
      final value = source[key];
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      if (value is num) return value.toDouble();
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Safely parses the load averages list from the source map.
  static List<double> _parseLoadList(Map<String, dynamic> source, String key) {
    try {
      final value = source[key];
      if (value is List) {
        return value.map((e) => _toDouble(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Converts a value to double, handling various types.
  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }

  /// Returns CPU usage as a formatted percentage string.
  String get usagePercentage => '${usage.toStringAsFixed(1)}%';

  /// Returns the 1-minute load average.
  double get load1Min => load.isNotEmpty ? load[0] : 0.0;

  /// Returns the 5-minute load average.
  double get load5Min => load.length > 1 ? load[1] : 0.0;

  /// Returns the 15-minute load average.
  double get load15Min => load.length > 2 ? load[2] : 0.0;

  /// Returns formatted load averages as a string.
  String get loadFormatted => load.map((l) => l.toStringAsFixed(2)).join(', ');

  /// Returns frequency formatted as GHz.
  String get freqGhz => '${(freqMhz / 1000).toStringAsFixed(2)} GHz';

  String get formattedModelName =>
      model.isNotEmpty ? model.split('CPU').first : 'Unknown';

  /// Checks if CPU data is available (has non-empty model).
  bool get hasData => model.isNotEmpty;
}

/// Represents network interface information including download speeds, upload speeds, and ping times.
/// This class is designed to parse and store network data from system monitoring commands.
///
/// The maps store data keyed by interface name (e.g., 'eth0', 'wlan0') for multi-interface support.
class Network {
  /// Download speeds per network interface.
  final Map<String, String> download;

  /// Upload speeds per network interface.
  final Map<String, String> upload;

  /// Ping times per network interface or target.
  final Map<String, String> ping;

  /// Creates a Network instance with empty maps.
  /// Use [Network.fromSource] for parsing actual data.
  const Network.empty()
      : download = const {},
        upload = const {},
        ping = const {};

  /// Creates a Network instance by parsing source data.
  ///
  /// [source] should be a Map containing network information, typically parsed from JSON output
  /// of system commands. Expected structure:
  /// {
  ///   "download": {"interface": "speed"},
  ///   "upload": {"interface": "speed"},
  ///   "ping": {"interface": "time"}
  /// }
  factory Network.fromSource(Map<String, dynamic> source) {
    return Network._internal(
      _parseNetworkMap(source, 'download'),
      _parseNetworkMap(source, 'upload'),
      _parseNetworkMap(source, 'ping'),
    );
  }

  /// Internal constructor for creating immutable instances.
  const Network._internal(this.download, this.upload, this.ping);

  /// Parses a network data map from source, handling various input formats safely.
  static Map<String, String> _parseNetworkMap(
      Map<String, dynamic> source, String key) {
    try {
      final data = source[key];
      if (data == null) return const {};

      if (data is Map<String, dynamic>) {
        // Handle nested map structure (e.g., per-interface data)
        return Map<String, String>.unmodifiable(
            data.map((k, v) => MapEntry(k.toString(), v.toString())));
      } else if (data is String) {
        // Handle single string value (default interface)
        return Map.unmodifiable({'default': data});
      } else {
        // Handle other types by converting to string
        return Map.unmodifiable({'default': data.toString()});
      }
    } catch (e) {
      // Return empty map on any parsing error to prevent crashes
      return const {};
    }
  }

  /// Returns an unmodifiable view of download speeds.
  Map<String, String> get downloadSpeeds => Map.unmodifiable(download);

  /// Returns an unmodifiable view of upload speeds.
  Map<String, String> get uploadSpeeds => Map.unmodifiable(upload);

  /// Returns an unmodifiable view of ping times.
  Map<String, String> get pingTimes => Map.unmodifiable(ping);

  /// Checks if any network data is available.
  bool get hasData =>
      download.isNotEmpty || upload.isNotEmpty || ping.isNotEmpty;

  /// Formats speed data safely, handling missing keys and null values.
  String _formatSpeed(Map<String, String> data) {
    final value = data['value'] ?? '0';
    final unit = data['unit'] ?? '';
    final formatted = '$value $unit'.trim();
    return formatted.isEmpty ? 'N/A' : formatted;
  }

  /// Returns the primary download speed (first available interface).
  String get primaryDownload => _formatSpeed(download);

  /// Returns the primary upload speed (first available interface).
  String get primaryUpload => _formatSpeed(upload);

  /// Returns the primary ping time (first available interface).
  String get primaryPing => _formatSpeed(ping);
}

class BasicDetails {
  /// Current logged-in user name
  final String user;

  /// System uptime information
  final String uptime;

  /// System temperature (may be empty if not available)
  final String temperature;

  /// RAM usage details
  final Ram ram;

  /// Disk usage details
  final List<Disk> disks;

  /// Network interface details
  final Network network;

  /// CPU usage and information
  final CPU cpu;

  /// Creates a BasicDetails instance with empty/default values.
  BasicDetails.empty()
      : user = '',
        uptime = '',
        temperature = '',
        ram = const Ram.empty(),
        disks = [],
        network = const Network.empty(),
        cpu = const CPU.empty();

  /// Creates a BasicDetails instance by parsing JSON source data.
  ///
  /// Expected source format: JSON string with basic system information.
  /// Handles missing keys and type conversion errors gracefully.
  factory BasicDetails(String source) {
    if (source.isEmpty) {
      return BasicDetails.empty();
    }

    try {
      final Map<String, dynamic> data =
          jsonDecode(source) as Map<String, dynamic>;
      return BasicDetails._internal(
        user: _parseString(data, 'username'),
        uptime: _parseString(data, 'uptime'),
        temperature: _parseString(data, 'temperature'),
        ram: Ram(data['ram']),
        disks: _parseDisks(data['disk']),
        network:
            Network.fromSource(data['network'] as Map<String, dynamic>? ?? {}),
        cpu: CPU.fromSource(data['cpu'] as Map<String, dynamic>? ?? {}),
      );
    } catch (e) {
      // Fallback to empty values on parsing error
      return BasicDetails.empty();
    }
  }

  const BasicDetails._internal({
    required this.user,
    required this.uptime,
    required this.temperature,
    required this.ram,
    required this.disks,
    required this.network,
    required this.cpu,
  });

  /// Safely parses a string value from the source map.
  static String _parseString(Map<String, dynamic> source, String key) {
    try {
      final value = source[key];
      return value?.toString() ?? '';
    } catch (e) {
      return '';
    }
  }

  static List<Disk> _parseDisks(List<dynamic>? disks) {
    if (disks == null) return [];
    return disks.map((disk) => Disk(disk as Map<String, dynamic>)).toList();
  }

  String get totalDiskUsed {
    int totalUsed = 0;
    for (var disk in disks) {
      totalUsed += disk.usedInBytes;
    }
    return filesize(totalUsed);
  }

  String get totalDiskSize {
    int totalSize = 0;
    for (var disk in disks) {
      totalSize += disk.sizeInBytes;
    }
    return filesize(totalSize);
  }

  double get diskUsagePercentage {
    int totalUsed = 0;
    int totalSize = 0;
    for (var disk in disks) {
      totalUsed += disk.usedInBytes;
      totalSize += disk.sizeInBytes;
    }
    if (totalSize == 0) return 0.0;
    return totalUsed / totalSize;
  }

  String get diskUsagePercentageString =>
      "${(diskUsagePercentage * 100).toStringAsFixed(2)}%";

  String get ramUsed {
    return filesize(ram.ramUsageInBytes.toInt());
  }

  String get ramSize {
    return filesize(ram.ramSizeInBytes.toInt());
  }

  /// Checks if basic details data is available (has non-empty user or uptime).
  bool get hasData => user.isNotEmpty || uptime.isNotEmpty;
  String get getTemperature =>
      temperature.isEmpty ? "0" : temperature.replaceAll("+", "");

  String get getUptime => uptime.split(",").first;
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
      try {
        Map jsonData = jsonDecode(commandOutput);
        upload = jsonData["upload"].toString().split(".").first;
        download = jsonData["download"].toString().split(".").first;
        ping = jsonData["ping"].toString();
        country = jsonData["client"]["country"].toString();
        isp = jsonData["client"]["isp"].toString();
      } catch (_) {}
    }
  }

  String get uploadSpeed => "${filesize(upload)}/S";
  String get downloadSpeed => "${filesize(download)}/S";
}
