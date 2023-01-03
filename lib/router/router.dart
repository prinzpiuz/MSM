// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:msm/providers/app_provider.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/views/file_listing/file_listing.dart';
import 'package:msm/views/home/home.dart';
import 'package:msm/views/settings/app_info.dart';
import 'package:msm/views/settings/folder_configuration.dart';
import 'package:msm/views/settings/server_details.dart';
import 'package:msm/views/settings/settings.dart';
import 'package:msm/views/settings/wol_details.dart';
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
        builder: (context, state) => const Sytemtools(),
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
              builder: (context, state) => const FolderConfiguration(),
            ),
            GoRoute(
              path: SettingsSubRoute.wakeOnLan.toPath,
              name: SettingsSubRoute.wakeOnLan.toName,
              builder: (context, state) => const WOLDetails(),
            ),
            GoRoute(
              path: SettingsSubRoute.appInfo.toPath,
              name: SettingsSubRoute.appInfo.toName,
              builder: (context, state) => const AppInfo(),
            ),
          ])
    ],
    // errorBuilder: (context, state) => ErrorPage(error: state.error.toString()),
    redirect: (state) {
      debugPrint(state.subloc);
      //   final homeLocation = state.namedLocation(Pages.home.toName);
      //   // final splashLocation = state.namedLocation(Pages.splash.toName);
      //   // final onboardLocation = state.namedLocation(Pages.onBoarding.toName);
      //   return homeLocation;
      //TODO redirect logics

      // final isLogedIn = appService.loginState;
      // final isInitialized = appService.initialized;
      // final isOnboarded = appService.onboarding;

      // final isGoingToLogin = state.subloc == loginLocation;
      // final isGoingToInit = state.subloc == splashLocation;
      // final isGoingToOnboard = state.subloc == onboardLocation;

      // // If not Initialized and not going to Initialized redirect to Splash
      // if (!isInitialized && !isGoingToInit) {
      //   return splashLocation;
      //   // If not onboard and not going to onboard redirect to OnBoarding
      // } else if (isInitialized && !isOnboarded && !isGoingToOnboard) {
      //   return onboardLocation;
      //   // If not logedin and not going to login redirect to Login
      // } else if (isInitialized &&
      //     isOnboarded &&
      //     !isLogedIn &&
      //     !isGoingToLogin) {
      //   return loginLocation;
      //   // If all the scenarios are cleared but still going to any of that screen redirect to Home
      // } else if ((isLogedIn && isGoingToLogin) ||
      //     (isInitialized && isGoingToInit) ||
      //     (isOnboarded && isGoingToOnboard)) {
      //   return homeLocation;
      // } else {
      //   // Else Don't do anything
      return null;
      // }
    },
  );
}
