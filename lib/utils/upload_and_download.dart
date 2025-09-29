// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dartssh2/dartssh2.dart';

// Project imports:
import 'package:msm/constants/constants.dart';
import 'package:msm/utils/file_manager.dart';
import 'package:msm/utils/local_notification.dart';

Future<SftpClient> getSFTPClient(dynamic event) async {
  SSHClient client = SSHClient(
    await SSHSocket.connect(
      event["serverHost"],
      int.parse(event["portNumber"]),
      timeout: const Duration(seconds: 10),
    ),
    username: event["username"].trim(),
    onPasswordRequest: () => event["rootPassword"],
  );
  final SftpClient sftpClient = await client.sftp();
  return sftpClient;
}

Future<void> upload(
    {List<String> newFolders = const [],
    String insidePath = "",
    required String directory,
    required List<String> filePaths,
    required SftpClient? sftp,
    required Notifications? notifications}) async {
  if (filePaths.isNotEmpty) {
    if (insidePath.isNotEmpty) {
      directory = "$directory/$insidePath";
    }
    if (newFolders.isEmpty) {
      loopAndSend(
          filePaths: filePaths,
          directory: directory,
          notifications: notifications,
          sftp: sftp);
    } else {
      await _createFolders(
              directory: directory,
              newFolders: newFolders,
              sftp: sftp,
              notifications: notifications)
          .then((createdDirectoryPath) async {
        loopAndSend(
            filePaths: filePaths,
            directory: createdDirectoryPath,
            notifications: notifications,
            sftp: sftp);
      });
    }
  } else {
    notifications!.uploadError(error: AppMessages.filesNotSelected);
  }
}

Future<String> _createFolders(
    {required String directory,
    required List<String> newFolders,
    required SftpClient? sftp,
    required Notifications? notifications}) async {
  try {
    for (String folder in newFolders) {
      directory += "/$folder";
      await sftp!.mkdir(directory);
    }
    return directory;
  } catch (_) {
    notifications!.uploadError(error: AppMessages.folderCreationError);
    return AppMessages.folderCreationError;
  }
}

Future<void> notify(
    {required String fileName,
    required String location,
    required int fileSize,
    required int progress,
    required Notifications? notifications,
    required NotificationType notificationType}) async {
  await notifications!.uploadNotification(
      name: fileName,
      location: location,
      progress: progress,
      fileSize: fileSize,
      notificationType: notificationType);
}

void loopAndSend(
    {required List<String> filePaths,
    required String directory,
    required SftpClient? sftp,
    required Notifications? notifications}) {
  for (String filePath in filePaths) {
    sendFile(
        directory: directory,
        filePath: filePath,
        sftp: sftp,
        notifications: notifications);
  }
}

Future<void> sendFile(
    {required String directory,
    required String filePath,
    required SftpClient? sftp,
    required Notifications? notifications}) async {
  try {
    if (sftp != null) {
      final int totalFileSize = File(filePath).lengthSync();
      final String fileName = filePath.split('/').last.toString();
      final String remotePath = "$directory/$fileName";
      final remoteFile = await sftp.open(remotePath,
          mode: SftpFileOpenMode.create | SftpFileOpenMode.write);
      await remoteFile.write(
        File(filePath).openRead().cast(),
        onProgress: (progress) => notify(
            fileName: fileName,
            location: directory,
            fileSize: totalFileSize,
            progress: progress,
            notificationType: NotificationType.upload,
            notifications: notifications),
      );
    } else {
      notifications!.uploadError(error: AppMessages.serverNotAvailable);
    }
  } catch (e) {
    notifications!.uploadError(error: e.toString());
  }
}

Future<void> download(
    {required SftpClient? sftp,
    required Notifications? notifications,
    required String fullPath,
    required String name}) async {
  try {
    final remoteFile = await sftp!.open(fullPath);
    File localFileObj = File("${FileManager.downloadLocation}/$name");
    final size = (await remoteFile.stat()).size;
    const defaultChunkSize = 1024 * 1024 * 10; //10MB
    if (size != null) {
      int chunkSize = size > defaultChunkSize ? defaultChunkSize : size;
      for (var i = chunkSize; chunkSize > 0; i += chunkSize) {
        final fileData = await remoteFile.readBytes(
            length: chunkSize, offset: i - chunkSize);
        await localFileObj.writeAsBytes(fileData,
            mode: FileMode.append, flush: true);
        notify(
            fileName: name,
            location: FileManager.downloadLocation,
            fileSize: size,
            progress: i,
            notificationType: NotificationType.download,
            notifications: notifications);
        if (i + chunkSize > size) {
          chunkSize = size - i;
        }
      }
    }
  } catch (_) {}
}
