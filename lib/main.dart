// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:msm/initialization.dart';
import 'package:msm/models/storage.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/providers/file_listing_provider.dart';
import 'package:msm/providers/folder_configuration_provider.dart';
import 'package:msm/providers/upload_provider.dart';
import 'package:msm/views/splash/splash.dart';
import 'config.dart';

void main() {
  runApp(const MSM());
}

class MSM extends StatefulWidget {
  const MSM({Key? key}) : super(key: key);

  @override
  State<MSM> createState() => _MSMState();
}

class _MSMState extends State<MSM> {
  final Future _initFuture = Init().initialize();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
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
          //TODO make splash screen neat
          return SplashScreen();
        }
      },
    );
  }
}
