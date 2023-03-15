// Package imports:
import 'package:workmanager/workmanager.dart';

// Project imports:
import 'package:msm/constants/constants.dart';
import 'package:msm/initialization.dart';
import 'package:msm/providers/app_provider.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case BackgroundTaskUniqueNames.upload:
        await Init().initialize(background: true).then((value) async {
          AppService appservice = value["appService"];
          if (inputData != null) {
            List<String>? fileUploadData = (inputData['fileUploadData'] as List)
                .map((item) => item as String)
                .toList();
            List<String>? newFolders = (inputData['newFolders'] as List)
                .map((item) => item as String)
                .toList();
            await appservice.server.connect().then((value) async {
              appservice.commandExecuter.client = value;
              await appservice.commandExecuter.upload(
                  directory: inputData["directory"],
                  filePaths: fileUploadData,
                  insidPath: inputData["insidPath"],
                  newFolders: newFolders);
            });
          }
        });
        break;
      case BackgroundTaskUniqueNames.update:
        break;
      case BackgroundTaskUniqueNames.cleanServer:
        break;
    }
    return Future.value(true);
  });
}

enum Tasks { upload, update, cleanServer }

extension TasksExtension on Tasks {
  String get uniqueName {
    switch (this) {
      case Tasks.upload:
        return BackgroundTaskUniqueNames.upload;
      case Tasks.update:
        return BackgroundTaskUniqueNames.update;
      case Tasks.cleanServer:
        return BackgroundTaskUniqueNames.cleanServer;
    }
  }
}

Constraints get constraints => Constraints(
    networkType: NetworkType.connected,
    requiresBatteryNotLow: true,
    requiresCharging: false,
    requiresDeviceIdle: false,
    requiresStorageNotLow: false);

class BackgroundTasks {
  BackgroundTasks() {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }

  void uploadTask({data}) {
    Workmanager().registerOneOffTask(
      Tasks.upload.uniqueName,
      Tasks.upload.uniqueName,
      inputData: data,
      constraints: constraints,
    );
  }
}
