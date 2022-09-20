// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:msm/providers/app_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
  late AppService appService;

  @override
  void initState() {
    appService = AppService();
    requestPermissions();
    super.initState();
  }

  void requestPermissions() async {
    await [Permission.storage].request();
  }

  @override
  Widget build(BuildContext context) {
    return materialApp(appService);
  }
}
