// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Project imports:
import 'package:msm/common_utils.dart';
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
      backgroundColor: CommonColors.commonWhiteColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.h),
          child: StaggeredGrid.count(
            crossAxisCount: 4,
            mainAxisSpacing: 4.h,
            crossAxisSpacing: 4.h,
            children: tiles(context),
          ),
        ),
      ));
}
