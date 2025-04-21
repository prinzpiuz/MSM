// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:msm/initialization.dart';
import 'package:msm/views/splash/init_screen.dart';

import 'config.dart';

void main() {
  runApp(const MSM());
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
