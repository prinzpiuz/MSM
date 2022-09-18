// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/font_sizes.dart';
import 'package:msm/helpers/common_utils.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/views/ui_components/text.dart';
import 'package:msm/views/ui_components/textstyles.dart';
import 'package:msm/views/upload_pages/upload_page_utils.dart';
import 'package:permission_handler/permission_handler.dart';

class CommonUploadPage extends StatefulWidget {
  const CommonUploadPage({Key? key}) : super(key: key);

  @override
  CommonUploadPageState createState() => CommonUploadPageState();
}

class CommonUploadPageState extends State<CommonUploadPage> {
  @override
  void initState() {
    getFiles();

    super.initState();
  }

  void getFiles() async {
    Directory dir = Directory('/storage/emulated/0/Movies');
    debugPrint(dir.path);
    if (await Permission.storage.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      debugPrint(dir.listSync(recursive: true).whereType<File>().toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return handleBackButton(
        child: commonUpload(context),
        context: context,
        backRoute: Pages.upload.toPath);
  }
}

Widget commonUpload(BuildContext context) {
  return Scaffold(
      appBar: commonAppBar(context: context),
      backgroundColor: CommonColors.commonWhiteColor,
      body: Column(
        children: <Widget>[uploadItemCard(context)],
      ));
}

Widget uploadItemCard(BuildContext context) {
  return Padding(
    padding: EdgeInsets.only(top: 10.h),
    child: Stack(
      children: [
        Center(
          child: Card(
            elevation: 3,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: SizedBox(
              width: 300.w,
              height: 122.h,
              child: Padding(
                padding: EdgeInsets.all(15.h),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.singleLineText(
                          "Bacurau.2019.720p.BluRay.x264.AAC-[YTS.MX].mp4",
                          style: AppTextStyles.medium(
                              CommonColors.commonBlackColor, 15)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.text("Downloads",
                              style: AppTextStyles.medium(
                                  CommonColors.commonGreyColor, 10)),
                          AppText.text("MKV, 1GB",
                              style: AppTextStyles.medium(
                                  CommonColors.commonGreyColor, 10))
                        ],
                      )
                    ]),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 15.h,
          right: 50.w,
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: CommonColors.commonGreenColor),
            child: IconButton(
                onPressed: (() => debugPrint("added")),
                icon: Icon(
                  Icons.add,
                  color: CommonColors.commonWhiteColor,
                  size: 35.h,
                )),
          ),
        )
      ],
    ),
  );
}
