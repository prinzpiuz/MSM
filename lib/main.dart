// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:sentry_flutter/sentry_flutter.dart';

// Project imports:
import 'package:msm/initialization.dart';
import 'package:msm/views/splash/init_screen.dart';
import 'config.dart';

Future<void> main() async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) exit(1);
  };
  const String sentryDSN = String.fromEnvironment('SENTRY_DSN');
  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDSN;
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(const MSM()),
  );
}

class MSM extends StatefulWidget {
  const MSM({super.key});

  @override
  State<MSM> createState() => _MSMState();
}

class _MSMState extends State<MSM> {
  final Future _initApp = Init().initialize();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initApp,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          var data = snapshot.data as Map<String, dynamic>;
          return materialApp(
              appService: data["appService"],
              uploadService: data["uploadService"],
              fileListingService: data["fileListingService"],
              folderConfigState: data["folderConfigState"]);
        } else {
          return const InitScreen();
        }
      },
    );
  }
}
