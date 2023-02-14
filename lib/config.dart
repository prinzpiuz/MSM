// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:msm/providers/folder_configuration_provider.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:msm/providers/app_provider.dart';
import 'package:msm/providers/file_listing_provider.dart';
import 'package:msm/providers/upload_provider.dart';
import 'package:msm/router/router.dart';

bool get appENV {
  bool isProd = const bool.fromEnvironment('dart.vm.product');
  return isProd;
}

MultiProvider materialApp(AppService appService, UploadState uploadService,
    FileListingState fileListingService, FolderConfigState folderConfigState) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AppService>(create: (_) => appService),
      ChangeNotifierProvider<UploadState>(create: (_) => uploadService),
      ChangeNotifierProvider<FileListingState>(
          create: (_) => fileListingService),
      ChangeNotifierProvider<FolderConfigState>(
          create: (_) => folderConfigState),
      Provider<AppRouter>(create: (_) => AppRouter(appService)),
    ],
    child: Builder(
      builder: (context) {
        final GoRouter goRouter =
            Provider.of<AppRouter>(context, listen: false).router;
        return ScreenUtilInit(
          builder: (_, child) {
            return MaterialApp.router(
              title: "MSM",
              routeInformationProvider: goRouter.routeInformationProvider,
              routeInformationParser: goRouter.routeInformationParser,
              routerDelegate: goRouter.routerDelegate,
              theme: ThemeData(
                textTheme:
                    Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
              ),
            );
          },
        );
      },
    ),
  );
}
