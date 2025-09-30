// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:msm/utils.dart';
import 'package:msm/common_widgets.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/views/upload_pages/upload_page_utils.dart';

class UploadMenuPage extends StatefulWidget {
  const UploadMenuPage({super.key});

  @override
  UploadMenuPageState createState() => UploadMenuPageState();
}

class UploadMenuPageState extends State<UploadMenuPage> {
  @override
  Widget build(BuildContext context) {
    return handleBackButton(
        child: uploadMenu(context),
        context: context,
        backRoute: Pages.home.toPath);
  }
}

Widget uploadMenu(BuildContext context) {
  return Scaffold(
      appBar: commonAppBar(
          text: Pages.upload.toTitle,
          backroute: Pages.home.toPath,
          context: context),
      backgroundColor: CommonColors.commonWhiteColor,
      body: ListView(
        children: locations(context),
      ));
}
