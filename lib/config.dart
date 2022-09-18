// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:msm/providers/app_provider.dart';
import 'package:msm/router/router.dart';

bool get appENV {
  bool isProd = const bool.fromEnvironment('dart.vm.product');
  return isProd;
}

MultiProvider materialApp(AppService appService) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AppService>(create: (_) => appService),
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
