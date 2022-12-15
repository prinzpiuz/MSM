// Flutter imports:
import 'package:flutter/widgets.dart';
import 'package:msm/providers/file_listing_provider.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:msm/providers/app_provider.dart';
import 'package:msm/providers/upload_provider.dart';
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
  late UploadState uploadService;
  late FileListingState fileListingService;

  @override
  void initState() {
    appService = AppService();
    uploadService = UploadState();
    fileListingService = FileListingState();
    requestPermissions();
    super.initState();
  }

  void requestPermissions() async {
    await [Permission.storage].request();
  }

  @override
  Widget build(BuildContext context) {
    return materialApp(appService, uploadService, fileListingService);
  }
}
