// Package imports:
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:msm/models/server.dart';
import 'package:msm/models/storage.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/providers/file_listing_provider.dart';
import 'package:msm/providers/folder_configuration_provider.dart';
import 'package:msm/providers/upload_provider.dart';

class Init {
  late AppService appService;
  late UploadState uploadService;
  late FileListingState fileListingService;
  late FolderConfigState folderConfigState;

  Future<Map<String, dynamic>> initialize() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Storage storage = Storage(prefs: sharedPreferences);
    appService = AppService(
        server: Server(
            serverData: storage.getServerData,
            folderConfiguration: storage.getFolderConfigurations,
            serverFunctionsData: storage.getServerFunctions),
        storage: storage);
    uploadService = UploadState();
    fileListingService = FileListingState();
    folderConfigState = FolderConfigState();
    await [Permission.storage].request();
    return {
      "appService": appService,
      "uploadService": uploadService,
      "fileListingService": fileListingService,
      "folderConfigState": folderConfigState
    };
  }
}
