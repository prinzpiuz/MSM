// Package imports:
import 'package:dartssh2/dartssh2.dart';
import 'package:msm/models/file_upload.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:msm/models/commands/command_executer.dart';
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
    Storage storage = await _getUserPreferences();
    AppService appService = AppService(
        server: Server(
            serverData: storage.getServerData,
            folderConfiguration: storage.getFolderConfigurations,
            serverFunctionsData: storage.getServerFunctions),
        storage: storage);
    UploadState uploadService = UploadState();
    FileListingState fileListingService = FileListingState();
    FolderConfigState folderConfigState = FolderConfigState();
    _requestStoragePermissions();
    appService.commandExecuter = CommandExecuter(
      serverData: appService.server.serverData,
      folderConfiguration: appService.server.folderConfiguration,
      serverFunctionsData: appService.server.serverFunctionsData,
      client: null,
    );
    makeConnections(appService, uploadState: uploadService);
    return {
      "appService": appService,
      "uploadService": uploadService,
      "fileListingService": fileListingService,
      "folderConfigState": folderConfigState
    };
  }

  static Future<Storage> _getUserPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Storage storage = Storage(prefs: sharedPreferences);
    return storage;
  }

  static void makeConnections(AppService appService,
      {UploadState? uploadState}) async {
    appService.initialized = true;
    appService.server.state = ServerState.connecting;
    if (appService.server.serverData.detailsAvailable) {
      SSHClient? client = await appService.server.connect().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          appService.connectionState = false;
          return null;
        },
      );
      if (client != null) {
        appService.commandExecuter = CommandExecuter(
            serverData: appService.server.serverData,
            folderConfiguration: appService.server.folderConfiguration,
            serverFunctionsData: appService.server.serverFunctionsData,
            client: client);
        appService.connectionState = true;
        appService.server.state = ServerState.connected;
        if (uploadState != null) {
          uploadState.fileUpload = FileUpload(client);
        }
      }
    }
  }

  static void _requestStoragePermissions() async {
    await [Permission.storage].request();
    await [Permission.manageExternalStorage].request();
  }
}
