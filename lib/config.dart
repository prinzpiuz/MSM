// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

bool get appENV {
  bool isProd = const bool.fromEnvironment('dart.vm.product');
  return isProd;
}

ScreenUtilInit materialApp(Widget homePage) {
  return ScreenUtilInit(
    builder: (_, child) {
      return MaterialApp(
        title: 'MSM',
        theme: ThemeData(
          textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
        ),
        home: child,
      );
    },
    child: homePage,
  );
}
