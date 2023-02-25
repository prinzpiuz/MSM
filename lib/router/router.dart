// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:dartssh2/dartssh2.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:msm/models/storage.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/views/file_listing/file_listing.dart';
import 'package:msm/views/home/home.dart';
import 'package:msm/views/settings/app_info.dart';
import 'package:msm/views/settings/folder_configuration_view.dart';
import 'package:msm/views/settings/server_details_view.dart';
import 'package:msm/views/settings/server_functions_view.dart';
import 'package:msm/views/settings/settings.dart';
import 'package:msm/views/system_tools/system_tools.dart';
import 'package:msm/views/upload_pages/common_upload_interface.dart';
import 'package:msm/views/upload_pages/upload_menu.dart';

class AppRouter {
  late final AppService appService;
  GoRouter get router => _goRouter;

  AppRouter(this.appService);

  late final GoRouter _goRouter = GoRouter(
    refreshListenable: appService,
    initialLocation: Pages.home.toPath,
    routes: <GoRoute>[
      GoRoute(
        path: Pages.home.toPath,
        name: Pages.home.toName,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: Pages.upload.toPath,
        name: Pages.upload.toName,
        builder: (context, state) => const UploadMenuPage(),
      ),
      GoRoute(
        path: Pages.commonUpload.toPath,
        name: Pages.commonUpload.toName,
        builder: (context, state) => const CommonUploadPage(),
      ),
      GoRoute(
        path: Pages.systemTools.toPath,
        name: Pages.systemTools.toName,
        builder: (context, state) => const SystemTools(),
      ),
      GoRoute(
        path: Pages.fileList.toPath,
        name: Pages.fileList.toName,
        builder: (context, state) => const FileListing(),
      ),
      GoRoute(
          path: Pages.settings.toPath,
          name: Pages.settings.toName,
          builder: (context, state) => const Settings(),
          routes: [
            GoRoute(
              path: SettingsSubRoute.serverDetails.toPath,
              name: SettingsSubRoute.serverDetails.toName,
              builder: (context, state) => const ServerDetails(),
            ),
            GoRoute(
              path: SettingsSubRoute.folderConfiguration.toPath,
              name: SettingsSubRoute.folderConfiguration.toName,
              builder: (context, state) => const FolderConfigurationForm(),
            ),
            GoRoute(
              path: SettingsSubRoute.serverFunctions.toPath,
              name: SettingsSubRoute.serverFunctions.toName,
              builder: (context, state) => const ServerFunctions(),
            ),
            GoRoute(
              path: SettingsSubRoute.appInfo.toPath,
              name: SettingsSubRoute.appInfo.toName,
              builder: (context, state) => const AppInfo(),
            ),
          ])
    ],
    redirect: (context, state) async {
      if (!appService.server.serverData.detailsAvailable) {
        return "${Pages.settings.toPath}/${SettingsSubRoute.serverDetails.toPath}";
      }
      return null;
    },
  );
}
